local dap = require('dap')
if vim.g.nvim_dap_custom_attach_cache == nil then
  vim.g.nvim_dap_custom_attach_cache = {
    port = 5678,
    host = 'localhost'
  }
end

local get_vscode_launch_json = function()
  local launch_json = '.vscode/launch.json'
  local opts = { patterns = { launch_json } }
  local ok, project_root_path = pcall(vim.fn['utils#get_root_dir'], opts)
  if not ok then
    return nil
  end
  local launch_json_path = project_root_path .. '/' .. launch_json
  return launch_json_path
end

local is_bp_list_opened = function()
  local condition =
  "v:val.quickfix && get(v:val.variables, 'title', get(v:val.variables, 'quickfix_title', '')) == 'DAP Breakpoints'"
  local qf_list = vim.fn.filter(vim.fn.getwininfo(), condition)
  return next(qf_list) ~= nil
end

-- loads vscode configurations if exists on start or continue
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

-- if session is running, disconnect or terminate depending on request
local custom_close = function()
  local session = dap.session()
  if not session then
    return
  end
  if session['config'] and session['config'].request == "attach" then
    return dap.disconnect()
  end
  return dap.terminate()
end

local toggle_list_breakpoints = function()
  if is_bp_list_opened() then
    return vim.api.nvim_command("cclose")
  end
  return dap.list_breakpoints(1)
end

local custom_session_init = function()
  dap.set_exception_breakpoints({ "uncaughted", "uncaught" })
end

local custom_session_cleanup = function()
  dap.repl.close()
  if is_bp_list_opened() then
    vim.api.nvim_command("cclose")
  end
end

local attach_debugger = function(port, host, type)
  local config = {
    name = vim.fn.expand('%:t'),
    request = 'attach',
    type = type or vim.bo.filetype,
    port = port,
    host = host
  }
  dap.run(config)
end

local test_debugger = function()
  local port = vim.g.test_debug_port or 5678
  return attach_debugger(port, 'localhost')
end

local custom_attach = function()
  local prev_host = vim.g.nvim_dap_custom_attach_cache.host
  local prev_port = vim.g.nvim_dap_custom_attach_cache.port
  local host = vim.fn.input("Add host: ", prev_host)
  if host == '' then
    return print("Abort!")
  end
  local port = vim.fn.input("Add port: ", prev_port)
  if host == '' then
    return print("Abort!")
  end
  vim.g.nvim_dap_custom_attach_cache.port = port
  vim.g.nvim_dap_custom_attach_cache.host = host
  return attach_debugger(port, host)
end

-- on session init and cleanup
-- TODO: add reconnect logic if request is attach
dap.listeners.after.event_initialized["dap_init"] = custom_session_init
dap.listeners.before.event_terminated["dap_cleanup"] = custom_session_cleanup
dap.listeners.before.event_exited["dap_cleanup"] = custom_session_cleanup
dap.defaults.fallback.terminal_win_cmd = '50vsplit new'

-- keymaps - there are more but I mostly just use REPL
vim.keymap.set('n', '<leader>dd', custom_continue)
vim.keymap.set('n', '<leader>da', custom_attach)
vim.keymap.set('n', '<leader>dc', custom_close)
vim.keymap.set('n', '<leader>dh', dap.toggle_breakpoint)
vim.keymap.set('n', '<leader>dA', toggle_list_breakpoints)
vim.keymap.set('n', '<leader>dx', dap.clear_breakpoints)
vim.keymap.set('n', '<leader>dE', function() dap.set_exception_breakpoints({ "all" }) end)
vim.keymap.set('n', '<leader>d?', function() require "dap.ui.widgets".hover() end)
vim.keymap.set('n', '<leader>di', function()
  local widgets = require "dap.ui.widgets";
  widgets.centered_float(widgets.scopes)
end)
vim.keymap.set('n', '<leader>dr', function() dap.repl.toggle({}, "vsplit") end)
vim.api.nvim_create_user_command('RunTestDebugger', test_debugger, {})

------ Python config --------
local get_python_path = function()
  local venv_path = os.getenv('VIRTUAL_ENV')
  if venv_path then
    return venv_path .. '/bin/python'
  end
  return vim.fn.trim(vim.fn.system("which python"))
end

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
      options = {
        source_filetype = 'python',
      }
    })
  else
    local command = config.command or get_python_path()
    cb({
      type = 'executable',
      command = command,
      args = { '-m', 'debugpy.adapter' },
      options = {
        source_filetype = 'python',
      }
    })
  end
end
------------------------------

local adapters = {
  python = python
  -- TODO: add other adapters
}
dap.adapters = adapters
