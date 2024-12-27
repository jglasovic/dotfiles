local venv_lsp = require('venv-lsp')
venv_lsp.init()

local lspconfig = require('lspconfig')
local util = require('lspconfig.util')
-- vim.lsp.set_log_level('DEBUG');
--
local ensure_installed_manson = {
  "pyright", "lua_ls", "jsonls", "vimls", "intelephense", "gopls", "ts_ls"
}

local manually_instaled = {
  'regal', 'rust_analyzer'
}

local format_timeout_ms = 5000

-- Dynamic configs
-- [Optional] server settings: { <server name> : config }
local server_settings_map = {
  lua_ls = {
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
          path = (function()
            local runtime_path = vim.split(package.path, ";")
            table.insert(runtime_path, "lua/?.lua")
            table.insert(runtime_path, "lua/?/init.lua")
            return runtime_path
          end)(),
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
  regal = {
    root_dir = function(fname)
      return util.find_git_ancestor(fname)
    end,
  },
  denols = {
    root_dir = util.root_pattern("deno.json", "deno.jsonc"),
  },
  ts_ls = {
    root_dir = util.root_pattern("package.json"),
    single_file_support = false
  }
}
--------------------------------------------------------

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

local list_workspaces = function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end

local lsp_restart = function()
  vim.diagnostic.reset()
  vim.cmd("LspRestart")
  vim.notify("LSP restarted")
end

vim.keymap.set('n', '<leader>lr', lsp_restart)
vim.keymap.set('n', '<leader>m', '<cmd>Mason<cr>', { silent = true })
vim.keymap.set('n', '<leader>N', vim.diagnostic.goto_prev)
vim.keymap.set('n', '<leader>n', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>,', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
  callback = function(args)
    local buffer = args.buf
    local client_id = args.data.client_id
    local client = vim.lsp.get_client_by_id(client_id)

    if client and client.supports_method("textDocument/formatting") then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = buffer,
        callback = function()
          vim.lsp.buf.format { timeout_ms = format_timeout_ms, async = false, id = client_id }
        end,
      })
    end

    vim.bo[buffer].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'

    local opts = { buffer = buffer }
    vim.keymap.set('n', '<leader>S', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gr', function() vim.lsp.buf.references({ includeDeclaration = false }) end, opts)
    vim.keymap.set('n', 'M', man_documentation, opts)
    vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>.', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>cf', function()
      vim.lsp.buf.format({ timeout_ms = format_timeout_ms, async = true })
    end
    , opts)
    -- workspace
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wL', list_workspaces, opts)
  end,
})

-- UI
local border = 'single'
-- Diagnostics display
vim.diagnostic.config({
  virtual_text = false,
  severity_sort = true,
  float = {
    border = border,
    focusable = false,
    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
    source = true,
    prefix = " ",
    scope = "cursor",
  },
})

-- Change border of documentation hover window, See https://github.com/neovim/neovim/pull/13998
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = border,
})
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  { border = border }
)
require('lspconfig.ui.windows').default_options.border = border

-- Show diagnostics in a pop-up window on hover
vim.api.nvim_create_autocmd('CursorHold', {
  group = vim.api.nvim_create_augroup('LspResetPopup', { clear = true }),
  callback = function()
    local current_cursor = vim.api.nvim_win_get_cursor(0)
    local last_popup_cursor = vim.w.lsp_diagnostics_last_cursor or { nil, nil }
    -- Show the popup diagnostics window,
    -- but only once for the current cursor location (unless moved afterwards).
    if not (current_cursor[1] == last_popup_cursor[1] and current_cursor[2] == last_popup_cursor[2]) then
      vim.w.lsp_diagnostics_last_cursor = current_cursor
      vim.diagnostic.open_float()
    end
  end

})

for _, diag in ipairs({ "Error", "Warn", "Info", "Hint" }) do
  vim.fn.sign_define("DiagnosticSign" .. diag, {
    text = "",
    texthl = "DiagnosticSign" .. diag,
    linehl = "",
    numhl = "DiagnosticSign" .. diag,
  })
end

local mason = require("mason")
mason.setup({ ui = { border = border } })

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

local mason_lsp = require("mason-lspconfig")
mason_lsp.setup_handlers({ setup_server })
mason_lsp.setup({ ensure_installed = ensure_installed_manson })

for _, server_name in ipairs(manually_instaled) do
  setup_server(server_name)
end
