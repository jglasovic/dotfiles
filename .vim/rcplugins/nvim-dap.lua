local dap = require('dap')

if vim.g.dap_init_finshed then
  return
end

local get_vscode_launch_json = function()
  local launch_json = '.vscode/launch.json'
  local opts = { patterns = { launch_json }, strict = 1 }
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

-- on session init and cleanup
dap.listeners.after.event_initialized["dap_init"] = custom_session_init
dap.listeners.before.event_terminated["dap_cleanup"] = custom_session_cleanup
dap.listeners.before.event_exited["dap_cleanup"] = custom_session_cleanup

-- keybindings - there are more but I mostly use just relp for everything
vim.keymap.set({ 'n', 't' }, '<leader>dc', custom_continue)
vim.keymap.set('n', '<leader>dx', custom_close)
vim.keymap.set('n', '<leader>dh', dap.toggle_breakpoint)
vim.keymap.set('n', '<leader>da', toggle_list_breakpoints)
vim.keymap.set('n', '<leader>dR', dap.clear_breakpoints)
vim.keymap.set('n', '<leader>dE', function() dap.set_exception_breakpoints({ "all" }) end)
vim.keymap.set('n', '<leader>di', function() require "dap.ui.widgets".hover() end)
vim.keymap.set('n', '<leader>dd', function()
  local widgets = require "dap.ui.widgets";
  widgets.centered_float(widgets.scopes)
end)
vim.keymap.set('n', '<leader>dr', function() dap.repl.toggle({}, "vsplit") end)


------ Python config --------
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
------------------------------

local adapters = {
  -- TODO: add other adapters
  python = python
}
dap.adapters = adapters
vim.g.dap_init_finished = true
