if not vim.fn.executable('gh') then
  return
end

local uv = (vim.uv or vim.loop)

local execute_command = function(command)
  local co = coroutine.running()
  local stdout = uv.new_pipe()
  local stderr = uv.new_pipe()
  local handle
  local stdout_output = {}
  local stderr_output = {}

  handle = uv.spawn('sh', {
    args = { '-c', command },
    stdio = { nil, stdout, stderr },
  }, function(code, _)
    stdout:read_stop()
    stderr:read_stop()
    stdout:close()
    stderr:close()
    handle:close()

    if code == 0 then
      coroutine.resume(co, nil, table.concat(stdout_output))
    else
      coroutine.resume(co, true, table.concat(stderr_output))
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
  local err, result = coroutine.yield()
  return err, result
end


local run_vim_diff_command = function(from, to)
  local cmd = 'GitDiff ' .. from .. ' ' .. to
  vim.schedule(function()
    vim.api.nvim_command(cmd)
  end)
end


local print_error = function(...)
  local text = table.concat({ ... }, "\n")
  local highlight_group = "ErrorMsg"
  vim.schedule(function()
    vim.api.nvim_echo({ { text, highlight_group } }, true, {})
  end)
end

local print_warning = function(...)
  local text = table.concat({ ... }, "\n")
  local highlight_group = "WarningMsg"
  vim.schedule(function()
    vim.api.nvim_echo({ { text, highlight_group } }, true, {})
  end)
end


local sync_base_branch = function(base_ref)
  local err, data
  err, data = execute_command('git fetch origin ' .. base_ref)
  if not err then
    return nil, 'origin/' .. base_ref
  end

  local format = "--jq='.defaultBranchRef.name'"
  local cmd = 'gh repo view --json=defaultBranchRef ' .. format
  err, data = execute_command(cmd)
  if err then
    return "Cannot find base branch origin " .. base_ref, data
  end
  local default_branch = nil
  for value in data:gmatch("[^\r\n]+") do
    if value then
      default_branch = value
    end
  end
  if default_branch == nil then
    return "Cannot find base branch origin " .. base_ref, data
  end

  print_warning('Missing [' .. base_ref .. '] trying to fetch the default base [' .. default_branch .. ']')
  err, data = execute_command('git fetch origin ' .. default_branch)
  if err then
    return "Error fetching origin " .. default_branch, data
  end
  return nil, 'origin/' .. default_branch
end


local sync_ref_branch = function(head_ref, pr_number)
  local err, data
  err, data = execute_command('git fetch origin ' .. head_ref)
  if not err then
    return nil, head_ref, 'origin/' .. head_ref
  end
  -- if error, the branch could be deleted (closed PR), create branch from PR(head)
  print_warning('Missing [' .. head_ref .. '] trying to fetch [pull/' .. pr_number .. '/head]')
  -- PR branch for the deleted
  local pr_branch = 'pr-' .. pr_number
  err, data = execute_command('git fetch origin pull/' .. pr_number .. '/head:' .. pr_branch)
  if err then
    return 'Cannot fetch origin ' .. head_ref, data, nil
  end
  return nil, pr_branch, pr_branch
end


local fetch_pr_data = function(pr_number)
  local err, data
  local format = "--jq='.baseRefName,.headRefName,.state,.mergeCommit.oid'"
  local cmd = 'gh pr view ' .. pr_number .. ' --json=state,mergeCommit,baseRefName,headRefName ' .. format
  err, data = execute_command(cmd)
  if err then
    return "Error fetching PR data", data
  end
  local keys = { "baseRefName", "headRefName", "state", "mergeCommit" }
  local response = { baseRefName = nil, headRefName = nil, state = nil, mergeCommit = nil }
  local i = 1
  for value in data:gmatch("[^\r\n]+") do
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

local async_pr_diff = function(pr_number, checkout)
  local success, err = pcall(function()
    print('Fetching PR information for #' .. pr_number)
    local err, data
    err, data = fetch_pr_data(pr_number)
    if err then
      return print_error(err, data)
    end

    local baseRefName = data.baseRefName
    local headRefName = data.headRefName
    local state = data.state
    local mergeCommit = data.mergeCommit

    print('Fetching base branch: ' .. baseRefName)
    err, data = sync_base_branch(baseRefName)
    if err then
      return print_error(err, data)
    end
    baseRefName = data
    if state == 'MERGED' and mergeCommit ~= 'null' then
      return run_vim_diff_command(mergeCommit .. '^', mergeCommit)
    end

    print('Fetching ref branch: ' .. headRefName)
    local originHeadRefName = nil
    err, headRefName, originHeadRefName = sync_ref_branch(headRefName, pr_number)
    if err then
      return print_error(err, headRefName)
    end
    if checkout ~= 0 then
      print("Running checkout on branch " .. headRefName)
      err, data = execute_command('git checkout ' .. headRefName)
      if not err then
        return run_vim_diff_command(baseRefName, ' ')
      end
      print_error("Error running checkout:", data)
      print_warning("Running diff without checkout to the branch [" .. headRefName .. "]")
    end
    return run_vim_diff_command(baseRefName, originHeadRefName)
  end)

  if not success then
    print_error(err)
  end
end

local async_pr_number = function(branch)
  vim.g.trigger_gh_pr_check = true
  local err, data = execute_command('gh pr view --json=number --jq=.number')
  if err then
    vim.g.gh_pr_number = ''
  else
    vim.g.gh_pr_number = data:match("%d+")
  end
  vim.g.trigger_gh_pr_check = false
  vim.g.gh_previous_branch = branch
end


function GhPr(pr_number, checkout)
  coroutine.wrap(async_pr_diff)(pr_number, checkout)
end

function GetGhPrNumber(branch)
  -- trigger async check only once on branch change
  if branch and branch ~= vim.g.gh_previous_branch and not vim.g.trigger_gh_pr_check then
    coroutine.wrap(async_pr_number)(branch)
  end
  return vim.g.gh_pr_number or ''
end
