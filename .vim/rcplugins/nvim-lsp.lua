-- Settings (only update this block for installed servers/formatters/linters)------------------------------
-- Note: every server manually installed thru the mason will automaticly be configured
-- even if it is missing from `ensure_installed` table
local ensure_installed = {
  "pyright", "lua_ls", "jsonls", "vimls", "rust_analyzer", "intelephense", "gopls"
}
local venv_lsp = require('venv-lsp')
venv_lsp.init()

local lspconfig = require('lspconfig')
local null_ls = require("null-ls")
-- Dynamic configs
local get_lua_runtime_path = function()
  local runtime_path = vim.split(package.path, ";")
  table.insert(runtime_path, "lua/?.lua")
  table.insert(runtime_path, "lua/?/init.lua")
  return runtime_path
end


-- formatter settings: { <formatter name> : config }
local formatter_settings_map = {
  black = {},
  ruff = {},
  phpcsfixer = {},
  prettier = {},
}

-- linter settings: { <linter name> : config }
local linter_settings_map = {
  ruff = {},
  mypy = {},
  phpcs = {},
  phpstan = {},
}

-- [Optional] server settings: { <server name> : config }
local server_settings_map = {
  lua_ls = {
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
          path = get_lua_runtime_path(),
        },
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
        },
        telemetry = {
          enable = false,
        },
      },
    }
  },
}
--------------------------------------------------------

-- Imports
local mason = require("mason")
local mason_lsp = require("mason-lspconfig")

-- Setup mason first if it is not setup already
if not mason.has_setup then
  mason.setup()
end

-- Mappings
local man_documentation = function()
  if vim.fn.index({ 'vim', 'help', 'lua' }, vim.bo.filetype) >= 0 then
    return vim.cmd('h ' .. vim.fn.expand('<cword>'))
  end
  if vim.bo.keywordprg ~= '' then
    return vim.cmd('!' .. vim.bo.keywordprg .. ' ' .. vim.fn.expand('<cword>'))
  end
  return print('Missing man documentation!')
end

local format = function()
  vim.lsp.buf.format { async = true }
end

local list_workspaces = function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end

local lsp_restart = function()
  vim.diagnostic.reset()
  vim.cmd("LspRestart")
  print("LSP restarted")
end

vim.keymap.set('n', '<leader>lr', lsp_restart)
vim.keymap.set('n', '<leader>m', '<cmd>Mason<cr>', { silent = true })
vim.keymap.set('n', '<leader>N', vim.diagnostic.goto_prev)
vim.keymap.set('n', '<leader>n', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>,', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local buffer = ev.buf
    local opts = { buffer = buffer }
    vim.bo[buffer].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>S', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'M', man_documentation, opts)
    vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>.', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>cf', format, opts)
    -- workspace
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wL', list_workspaces, opts)
  end,
})

-- Diagnostics display
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  severity_sort = true,
  float = {
    border = "single",
    focusable = false,
    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
    source = "always",
    prefix = " ",
    scope = "cursor",
  },
})
-- Show diagnostics in a pop-up window on hover
local lsp_diagnostics_popup_handler = function()
  local current_cursor = vim.api.nvim_win_get_cursor(0)
  local last_popup_cursor = vim.w.lsp_diagnostics_last_cursor or { nil, nil }
  -- Show the popup diagnostics window,
  -- but only once for the current cursor location (unless moved afterwards).
  if not (current_cursor[1] == last_popup_cursor[1] and current_cursor[2] == last_popup_cursor[2]) then
    vim.w.lsp_diagnostics_last_cursor = current_cursor
    vim.diagnostic.open_float()
  end
end

vim.api.nvim_create_autocmd('CursorHold', {
  group = vim.api.nvim_create_augroup('LspResetPopup', { clear = true }),
  callback = lsp_diagnostics_popup_handler
})

-- LSP config
-- mason setup installed servers
local global_capabilities = vim.lsp.protocol.make_client_capabilities()
global_capabilities.textDocument.completion.completionItem.snippetSupport = true
lspconfig.util.default_config = vim.tbl_extend("force", lspconfig.util.default_config, {
  capabilities = global_capabilities,
})

local setup_server = function(server_name)
  local config = {}
  if server_settings_map[server_name] then
    config = vim.tbl_deep_extend("force", config, server_settings_map[server_name])
  end
  lspconfig[server_name].setup(config)
end

local handlers = {
  -- setup all mason installed servers with default config
  function(server_name)
    setup_server(server_name)
  end
}
-- apply custom settings per server defined in configs
mason_lsp.setup_handlers(handlers)
mason_lsp.setup({ ensure_installed = ensure_installed })

local get_source = function(type, name)
  local none_ls_source = 'none-ls.' .. type .. '.' .. name
  local success_lsp_config, _ = pcall(require, none_ls_source)
  if success_lsp_config then
    return require(none_ls_source)
  end
  if null_ls.builtins[type] and null_ls.builtins[type][name] then
    return null_ls.builtins[type][name]
  end
end

-- null-ls setup
local sources    = {}
for linter, config in pairs(linter_settings_map) do
  local source = get_source('diagnostics', linter)
  if source then
    table.insert(sources, source.with(config))
  end
end
-- formatters
for formatter, config in pairs(formatter_settings_map) do
  local source = get_source('formatting', formatter)
  if source then
    table.insert(sources, source.with(config))
  end
end

-- format on save
local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = true })
local on_attach = function(client, bufnr)
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end
end

null_ls.setup({
  on_attach = on_attach,
  sources = sources,
})

-- global function for statusline
function GetDiagnosticsStatus()
  local bufnr = vim.fn.bufnr()
  local mapping = {
    error = 'E:',
    warn = 'W:',
    info = 'I:',
    hint = 'H:'
  }
  local diagnostics = {
    error = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR }),
    warn = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN }),
    info = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.INFO }),
    hint = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.HINT }),
  }
  local status_tbl = {}
  for key, value in pairs(diagnostics) do
    if value > 0 then
      table.insert(status_tbl, mapping[key] .. value)
    end
  end
  return table.concat(status_tbl, ' ')
end
