-- Configs ------------------------------------
-- Note: only update this table - { <type> = <executable config or {} (empty table) to only support attach req> }
local configs = {
  python = {},
}
------------------------------------------------


local function pick_process(opts)
  local pid = vim.fn['PickProcessID']()
  return pid or require("dap").ABORT
end

local dap = require('dap')
-- global attach
local attach = function(cb, config)
  local port = (config.connect or config).port
  local host = (config.connect or config).host or '127.0.0.1'
  -- fix host
  if host == 'localhost' then
    host = '127.0.0.1'
  end

  return cb({
    type = 'server',
    port = assert(port, '`connect.port` is required for `attach` configuration'),
    host = host,
    options = config
  })
end

local adapters = {}
for type, dap_config in pairs(configs) do
  adapters[type] = function(cb, config)
    if config.request == 'attach' then
      return attach(cb, config)
    end
    return cb(vim.tbl_extend("force", { type = "executable" }, config, dap_config))
  end
end
-- apply adapters
dap.adapters = adapters

-- custom attach cache
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
  print("Using: [" .. launch_json_path .. "]")
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
  return dap.list_breakpoints(true)
end

local custom_session_init = function()
  dap.set_exception_breakpoints("default")
end

local custom_session_cleanup = function()
  dap.repl.close()
  if is_bp_list_opened() then
    vim.api.nvim_command("cclose")
  end
end

local attach_debugger = function(port, host, name, type)
  local config = {
    name = name,
    request = 'attach',
    type = type or vim.bo.filetype,
    port = port,
    host = host,
    max_retries = 40 -- 10 seconds
  }
  dap.run(config)
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
  local name = vim.fn.expand('%:t')
  return attach_debugger(port, host, name)
end

local test_debugger = function()
  local host = "localhost"
  local port = vim.g.test_debug_port or 5678
  local name = vim.fn.expand('%:t')
  return attach_debugger(port, host, name)
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
vim.keymap.set('n', '<leader>dx', custom_close)
vim.keymap.set('n', '<leader>dh', dap.toggle_breakpoint)
vim.keymap.set('n', '<leader>dA', toggle_list_breakpoints)
vim.keymap.set('n', '<leader>dc', dap.clear_breakpoints)
vim.keymap.set('n', '<leader>dE', function() dap.set_exception_breakpoints({ "all" }) end)
vim.keymap.set('n', '<leader>d?', function() require "dap.ui.widgets".hover() end)
vim.keymap.set('n', '<leader>di', function()
  local widgets = require "dap.ui.widgets";
  widgets.centered_float(widgets.scopes)
end)
vim.keymap.set('n', '<leader>dr', function() dap.repl.toggle({}, "vsplit") end)

local dap_repl_group = vim.api.nvim_create_augroup("DapReplGroup", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = dap_repl_group,
  pattern = "dap-repl",
  callback = function()
    require('dap.ext.autocompl').attach()
  end,
  desc = "Enable DAP autocompletion for dap-repl filetype",
})

vim.api.nvim_create_user_command('RunTestDebugger', test_debugger, {})
