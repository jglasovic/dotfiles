local dap = require('dap')

if vim.g.dap_setup_initialized then
  return
end

local project_root_mappings = {}
-- local reconnect = false
local get_vscode_launch_json = function()
  local launch_json = '.vscode/launch.json'
  local file_dir = vim.fn.expand('%:p:h')
  if (project_root_mappings[file_dir] ~= nil) then
    return project_root_mappings[file_dir]
  end

  local workspace_folders = vim.fn['utils#get_workspace_folders'](file_dir)
  local root_patterns = { launch_json }
  local opts = { workspace_folders = workspace_folders, strict = 1 }
  local ok, project_root_path = pcall(vim.fn['utils#get_project_root_by_patterns'], file_dir, root_patterns, opts)
  if not ok then
    return nil
  end
  local launch_json_path = project_root_path .. '/' .. launch_json
  project_root_mappings[file_dir] = launch_json_path
  return launch_json_path
end

---------- Python config
local get_python_path = function()
  local venv_path = os.getenv('VIRTUAL_ENV')
  if venv_path then
    return venv_path .. '/bin/python'
  end
  return vim.fn.trim(vim.fn.system("which python"))
end

-- local enrich_config = function(config, on_config)
--   if not config.pythonPath and not config.python then
--     config.pythonPath = get_python_path()
--   end
--   on_config(config)
-- end

local python = function(cb, config)
  if config.request == 'attach' then
    local port = (config.connect or config).port
    local host = (config.connect or config).host or '127.0.0.1'
    if host == 'localhost' then
      host = '127.0.0.1'
    end
    cb({
      type = 'server',
      port = assert(port, '`connect.port` is required for a python `attach` configuration'),
      host = host,
      -- enrich_config = enrich_config,
      options = {
        source_filetype = 'python',
      }
    })
  else
    cb({
      type = 'executable',
      command = get_python_path(),
      args = { '-m', 'debugpy.adapter' },
      -- enrich_config = enrich_config,
      options = {
        source_filetype = 'python',
      }
    })
  end
end
---------------






local adapters = {
  -- TODO: add other adapters
  python = python
}

dap.adapters = adapters

local custom_continue = function()
  local session = dap.session()
  if not session then
    local vscode_launch_json = get_vscode_launch_json()
    if vscode_launch_json then
      require('dap.ext.vscode').load_launchjs(vscode_launch_json)
    end
  end
  dap.continue()
end

dap.listeners.after.event_initialized["dap_init"] = function()
  dap.set_exception_breakpoints({ "uncaughted", "uncaught" })
  dap.repl.open({}, "vsplit")
end
dap.listeners.before.event_terminated["dap_cleanup"] = function()
  dap.repl.close()
end
dap.listeners.before.event_exited["dap_cleanup"] = function()
  dap.repl.close()
end

local custom_close = function()
  local session = dap.session()
  if not session then
    return
  end
  if session.config.request == "attach" then
    dap.disconnect()
  end
  dap.terminate()
end


vim.keymap.set({ 'n', 't' }, '<leader>dn', custom_continue) -- start debugger or continue
vim.keymap.set('n', '<leader>dx', custom_close)
vim.keymap.set('n', '<leader>dh', dap.toggle_breakpoint)
vim.keymap.set('n', '<leader>da', dap.list_breakpoints)
vim.keymap.set('n', '<leader>dR', dap.clear_breakpoints)
vim.keymap.set('n', '<leader>dE', function() dap.set_exception_breakpoints({ "all" }) end)
vim.keymap.set('n', '<leader>di', function() require "dap.ui.widgets".hover() end)
vim.keymap.set('n', '<leader>d?', function()
  local widgets = require "dap.ui.widgets";
  widgets.centered_float(widgets.scopes)
end)
vim.keymap.set('n', '<leader>dr', function() dap.repl.toggle({}, "vsplit") end)

vim.g.dap_setup_initialized = true
