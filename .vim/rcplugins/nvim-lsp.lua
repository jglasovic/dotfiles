-- Settings (only update this block for installed servers/formatters/linters)------------------------------
-- Note: every server manually installed thru the mason will automaticly be configured
-- even if it is missing from `ensure_installed` table
local ensure_installed = {
  "pyright", "lua_ls", "jsonls", "vimls", "rust_analyzer", "intelephense", "gopls"
}

-- Dynamic configs
local get_lua_runtime_path = function()
  local runtime_path = vim.split(package.path, ";")
  table.insert(runtime_path, "lua/?.lua")
  table.insert(runtime_path, "lua/?/init.lua")
  return runtime_path
end

local utils = require("null-ls.utils")
local helpers = require("null-ls.helpers")
-- formatter settings: { <formatter name> : config }
local formatter_settings_map = {
  black = {
    timeout = 10000,
    cwd = helpers.cache.by_bufnr(
      function(params)
        return utils.root_pattern("pyproject.toml")(params.bufname)
      end)
  },
  -- isort = {},
  ruff = { timeout = 10000 }
}

-- linter settings: { <linter name> : config }
local linter_settings_map = {
  ruff = { timeout = 10000 },
  -- pylint = {
  --   timeout = 20000,
  --   extra_args = { "--rcfile", "$ROOT/.pylintrc" }
  -- },
  mypy = { timeout = 10000 }
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
  }
}
--------------------------------------------------------

-- Imports
local mason = require("mason")
local lspconfig = require('lspconfig')
local mason_lsp = require("mason-lspconfig")
local null_ls = require("null-ls")

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

local toggle_git_workspace = function(file)
  -- toggle git root workspace dir
  return function()
    local workspaces = vim.lsp.buf.list_workspace_folders()
    local git_root_dir = lspconfig.util.find_git_ancestor(file)
    local removed = false
    for _, workspace in pairs(workspaces) do
      if workspace == git_root_dir then
        print("Removing workspace: " .. git_root_dir)
        removed = true
        vim.lsp.buf.remove_workspace_folder(git_root_dir)
      end
    end
    if not removed then
      print("Adding workspace: " .. git_root_dir)
      vim.lsp.buf.add_workspace_folder(git_root_dir)
    end
  end
end

local format = function()
  vim.lsp.buf.format { async = true }
end

local list_workspaces = function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end

local lsp_restart = function()
  vim.cmd("LspRestart")
  print("LSP restarted")
end

vim.keymap.set('n', '<leader>lr', lsp_restart)
vim.keymap.set('n', '<leader>m', '<cmd>Mason<cr>', { silent = true })
vim.keymap.set('n', '<leader>N', vim.diagnostic.goto_prev)
vim.keymap.set('n', '<leader>n', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>,', vim.diagnostic.setloclist)

local lsp_conf_group = vim.api.nvim_create_augroup('UserLspConfig', {})
vim.api.nvim_create_autocmd('LspAttach', {
  group = lsp_conf_group,
  callback = function(ev)
    local buffer = ev.buf
    local opts = { buffer = buffer }
    vim.bo[buffer].omnifunc = 'v:lua.vim.lsp.omnifunc'
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
    vim.keymap.set('n', '<leader>wt', toggle_git_workspace(ev.file), opts)
  end,
})

-- Diagnostics display
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  severity_sort = true,
  float = { border = "single", focusable = false },
})
-- Show diagnostics in a pop-up window on hover
local lsp_diagnostics_popup_handler = function()
  local current_cursor = vim.api.nvim_win_get_cursor(0)
  local last_popup_cursor = vim.w.lsp_diagnostics_last_cursor or { nil, nil }
  -- Show the popup diagnostics window,
  -- but only once for the current cursor location (unless moved afterwards).
  if not (current_cursor[1] == last_popup_cursor[1] and current_cursor[2] == last_popup_cursor[2]) then
    vim.w.lsp_diagnostics_last_cursor = current_cursor
    vim.diagnostic.open_float(0, { scope = "cursor" })
  end
end

local reset_popup_group = vim.api.nvim_create_augroup('LspResetPopup', { clear = true })

vim.api.nvim_create_autocmd('CursorHold', {
  callback = lsp_diagnostics_popup_handler,
  group = reset_popup_group
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

-- null-ls setup
local next = next
local sources = {}
for linter, config in pairs(linter_settings_map) do
  if next(config) == nil then
    table.insert(sources, null_ls.builtins.diagnostics[linter])
  else
    table.insert(sources, null_ls.builtins.diagnostics[linter].with(config))
  end
end
-- formatters
for formatter, config in pairs(formatter_settings_map) do
  if next(config) == nil then
    table.insert(sources, null_ls.builtins.formatting[formatter])
  else
    table.insert(sources, null_ls.builtins.formatting[formatter].with(config))
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
  debug = true,
  on_attach = on_attach,
  sources = sources
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
