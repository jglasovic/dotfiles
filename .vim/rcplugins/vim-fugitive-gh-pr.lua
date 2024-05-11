if not vim.fn.executable('gh') then
  return
end

local exec_wrapper = function(cmd, args, callback)
  return ExecuteShellCommandAsync(cmd, args,
    function(code, signal, stdout_output, stderr_output)
      if code == 0 then
        return callback(nil, stdout_output)
      else
        return callback(true, stderr_output)
      end
    end
  )
end

local sync_base_branch = function(base_ref, callback)
  return exec_wrapper('git', { 'fetch', 'origin', base_ref },
    function(err)
      if not err then
        return callback(nil, base_ref)
      end
      return exec_wrapper('gh', { 'repo', 'view', '--json=defaultBranchRef' },
        function(err, default_branch)
          if err then
            return callback(true, "Cannot find base branch origin " .. base_ref)
          end
          -- TODO: parse | jq -r '.defaultBranchRef.name' and use name
          return exec_wrapper('git', { 'fetch', 'origin', default_branch },
            function(err)
              if err then
                callback(true, "Error fetching origin " .. default_branch)
              end
              return callback(nil, default_branch)
            end)
        end)
    end)
end


local sync_ref_branch = function(head_ref, pr_number, callback)
  return exec_wrapper('git', { 'fetch', 'origin', head_ref },
    function(err)
      if not err then
        return callback(nil, { head_ref, 'origin/' .. head_ref })
      end
      return exec_wrapper('git', { 'fetch', 'origin', 'pull/' .. pr_number .. '/head:' .. head_ref },
        function(err)
          if err then
            return callback(true, 'Cannot fetch origin ' .. head_ref)
          end
          return callback(nil, { head_ref, head_ref })
        end)
    end)
end


local fetch_pr_data = function(pr_number, callback)
  return exec_wrapper('gh', { 'pr', 'view', '--json=state,mergeCommit,baseRefName,headRefName', pr_number },
    function(err, data)
      if err then
        return callback(true, data)
      end
      local cmd = "jq -r '.baseRefName,.headRefName,.state,.mergeCommit.oid' <<< '" .. data .. "'"
      return exec_wrapper('sh', { '-c', cmd },
        function(err, data)
          if err then
            return callback(true, data)
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
          return callback(nil, response)
        end)
    end)
end

local run_vim_diff_command = function(from, to)
  local cmd = 'GitDiff ' .. from .. ' ' .. to
  vim.schedule(function()
    vim.api.nvim_command(cmd)
  end)
end


function GhPr(pr_number, checkout)
  print('Fetching PR information for #' .. pr_number)
  fetch_pr_data(pr_number,
    function(err, data)
      if err then
        vim.api.nvim_err_writeln(data)
        return
      end

      local baseRefName = data.baseRefName
      local headRefName = data.headRefName
      local state = data.state
      local mergeCommit = data.mergeCommit

      print('Fetching base branch: ' .. baseRefName)
      return sync_base_branch(baseRefName,
        function(err, data)
          if err then
            vim.api.nvim_err_writeln(data)
            return
          end
          if state == 'MERGED' and mergeCommit ~= 'null' then
            return run_vim_diff_command(mergeCommit .. '^', mergeCommit)
          end
          print('Fetching ref branch: ' .. headRefName)
          return sync_ref_branch(headRefName, pr_number,
            function(err, data)
              if err then
                vim.api.nvim_err_writeln(data)
                return
              end
              local headRefName = data[1]
              local originHeadRefName = data[2]
              return exec_wrapper('git', { 'merge-base', baseRefName, originHeadRefName },
                function(err, data)
                  if err then
                    vim.api.nvim_err_writeln(data)
                    return
                  end

                  local merge_base_commit_sha = nil
                  for value in data:gmatch("[^\r\n]+") do
                    if value then
                      merge_base_commit_sha = value
                    end
                  end
                  if merge_base_commit_sha == nil then
                    vim.api.nvim_err_writeln("Cannot find merge-base commit")
                    return
                  end
                  if checkout ~= 0 then
                    print("Running checkout on branch " .. headRefName)
                    return exec_wrapper('git', { 'checkout', headRefName },
                      function(err, data)
                        if err then
                          vim.api.nvim_err_writeln(data)
                          return
                        end
                        return run_vim_diff_command(merge_base_commit_sha, '')
                      end)
                  end
                  return run_vim_diff_command(merge_base_commit_sha, originHeadRefName)
                end)
            end)
        end)
    end)
end
