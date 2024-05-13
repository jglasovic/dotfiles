if not vim.fn.executable('gh') then
  return
end

-- could use plenary.nvim but decided to go with custom coroutines in lua
local uv = vim.loop

local execute_command = function(command)
  local co = coroutine.running()
  local stdout = uv.new_pipe()
  local stderr = uv.new_pipe()
  local handle
  local stdout_output = {}
  local stderr_output = {}

  handle = uv.spawn('sh', {
    args = {'-c', command},
    stdio = { nil, stdout, stderr },
  }, function(code, _)
    stdout:read_stop()
    stderr:read_stop()
    stdout:close()
    stderr:close()
    handle:close()

    if code == 0 then
      coroutine.resume(co, {nil, table.concat(stdout_output)})
    else
      coroutine.resume(co, {true, table.concat(stderr_output)})
    end
  end)

  uv.read_start(stdout, function(err, data)
    assert(not err, err)
    if data then
      table.insert(stdout_output, data)
    end
  end)

  uv.read_start(stderr, function(err, data)
    assert(not err, err)
    if data then
      table.insert(stderr_output, data)
    end
  end)
  local result = coroutine.yield()
  return result[1], result[2]
end


local sync_base_branch = function(base_ref)
  local err, _ = execute_command('git fetch origin '..base_ref)
  if not err then
    return nil, base_ref
  end
  local format="--jq='.defaultBranchRef.name'"
  local cmd ='gh repo view --json=defaultBranchRef '..format
  local err, default_branch = execute_command(cmd)
  if err then
    return true, "Cannot find base branch origin " .. base_ref
  end
  local err, _ = execute_command('git fetch origin'..default_branch)
  if err then
    return true, "Error fetching origin " .. default_branch
  end
  return nil, default_branch
end


local sync_ref_branch = function(head_ref, pr_number)
  local err, _ = execute_command('git fetch origin '..head_ref)
  if not err then
    return nil, {head_ref, 'origin/'..head_ref}
  end
  local err, _ = execute_command('git fetch origin pull/'..pr_number..'/head:'..head_ref)
  if err then
    return true, 'Cannot fetch origin ' .. head_ref
  end
  return nil, { head_ref, head_ref }
end


local fetch_pr_data = function(pr_number)
  local format = "--jq='.baseRefName,.headRefName,.state,.mergeCommit.oid'"
  local cmd = 'gh pr view '..pr_number..' --json=state,mergeCommit,baseRefName,headRefName '..format
  local err, output = execute_command(cmd)
  if err then
    return true, output
  end
  local keys = { "baseRefName", "headRefName", "state", "mergeCommit" }
  local response = { baseRefName = nil, headRefName = nil, state = nil, mergeCommit = nil }
  local i = 1
  for value in output:gmatch("[^\r\n]+") do
    local key = keys[i]
    if value == "null" then
      response[key] = nil
    else
      response[key] = value
    end
    i = i + 1
  end
  return nil, response
end

local find_merge_base = function(base,head)
  local err, data = execute_command('git merge-base '..base..' '..head)
  if err then
    return true, err
  end

  local merge_base_commit_sha = nil
  for value in data:gmatch("[^\r\n]+") do
    if value then
      merge_base_commit_sha = value
    end
  end
  if merge_base_commit_sha == nil then
    return true, "Cannot find merge-base commit"
  end
  return nil, merge_base_commit_sha
end

local run_vim_diff_command = function(from, to)
  local cmd = 'GitDiff ' .. from .. ' ' .. to
  vim.schedule(function()
    vim.api.nvim_command(cmd)
  end)
end

local main = function(pr_number, checkout)
  print('Fetching PR information for #' .. pr_number)
  local err, data = fetch_pr_data(pr_number)
  if err then
    vim.api.nvim_err_writeln(data)
    return
  end
  local baseRefName = data.baseRefName
  local headRefName = data.headRefName
  local state = data.state
  local mergeCommit = data.mergeCommit

  print('Fetching base branch: ' .. baseRefName)
  local err, data = sync_base_branch(baseRefName)
  if err then
    vim.api.nvim_err_writeln(data)
    return
  end
  if state == 'MERGED' and mergeCommit ~= 'null' then
    return run_vim_diff_command(mergeCommit .. '^', mergeCommit)
  end

  print('Fetching ref branch: ' .. headRefName)
  local err, data = sync_ref_branch(headRefName, pr_number)
  if err then
    vim.api.nvim_err_writeln(data)
    return
  end
  local headRefName = data[1]
  local originHeadRefName = data[2]
  local err, merge_base_commit_sha = find_merge_base(baseRefName, originHeadRefName)

  if err then
    vim.api.nvim_err_writeln(data)
    return
  end

  if checkout ~= 0 then
    print("Running checkout on branch " .. headRefName)
    local err, _ = execute_command('git checkout '..headRefName)
    if err then
      vim.api.nvim_err_writeln(data)
      return
    end
    return run_vim_diff_command(merge_base_commit_sha, '')
  end

  return run_vim_diff_command(merge_base_commit_sha, originHeadRefName)
end

function GhPr(pr_number, checkout)
  coroutine.wrap(main)(pr_number, checkout)
end
