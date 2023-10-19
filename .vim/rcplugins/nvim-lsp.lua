-- Settings (only update this block for installed servers/formatters/linters)------------------------------
-- Note: every server manually installed thru the mason will automaticly be configured
-- even if it is missing from `ensure_installed` table
local ensure_installed = {
  "pyright", "lua_ls", "jsonls", "vimls", "rust_analyzer", "intelephense", "gopls"
}

-- only exec once in setup if poetry cmd exists and pyproject.toml exist
local get_poetry_virtualenvs_path = function()
    local cache_key = 'poetry_virtualenvs_path'
    if vim.g[cache_key] then
      return vim.g[cache_key]
    end
    local virtualenvs_path = vim.fn.trim(vim.fn.system('poetry config -v -- virtualenvs.path'))
    vim.api.nvim_set_var(cache_key, virtualenvs_path)
    return virtualenvs_path
end

-- cache output for path input
--
local get_poetry_virtualenv = function(path)
    local cache_key = 'poetry_virtualenv_map'
    if not vim.g[cache_key] then
      vim.api.nvim_set_var(cache_key, vim.empty_dict())
    end

    local cache = vim.g[cache_key]
    if cache and cache[path] then
      return cache[path]
    end
    local cmd = 'poetry -C ' .. path .. ' env info -p'
    local virtualenv_full_path = vim.fn.trim(vim.fn.system(cmd))
    local virtualenvs_path = get_poetry_virtualenvs_path()
    local virtualenv = virtualenv_full_path:gsub(virtualenvs_path..'/', "")
    cache[path] = virtualenv
    vim.api.nvim_set_var(cache_key, cache)
    return virtualenv
end

-- Dynamic configs
local get_lua_runtime_path = function()
  local runtime_path = vim.split(package.path, ";")
  table.insert(runtime_path, "lua/?.lua")
  table.insert(runtime_path, "lua/?/init.lua")
  return runtime_path
end

local null_ls = require("null-ls")
local utils = require("null-ls.utils")
local helpers = require("null-ls.helpers")
local cache_key = 'cache_poetry_virtualenv_path'

if not vim.g[cache_key] then
  vim.api.nvim_set_var(cache_key, vim.empty_dict())
end

local get_poetry_virtual_env_bin_path = function(dir)
  if not vim.g[cache_key][dir] then
    local virtual_env_path = vim.fn.trim(vim.fn.system('poetry -C ' .. dir .. ' env info -p'))
    local cache = vim.g[cache_key]
    cache[dir] = virtual_env_path
    vim.api.nvim_set_var(cache_key, cache)
  end
  local bin_path = vim.g[cache_key][dir] .. '/bin'
  return bin_path
end

local get_poetry_bin_cmd_path = function(cmd)
  return function(opts)
    local buf_workspace_dir = helpers.cache.by_bufnr(function(params)
      return utils.root_pattern(
        "pyproject.toml"
      )(params.bufname)
    end)(opts)

    local virtual_env_path = get_poetry_virtual_env_bin_path(buf_workspace_dir)
    return virtual_env_path .. '/' .. cmd
  end
end

local on_new_config = function(new_config, new_root_dir)
  local poetry_virutalenv_bin = get_poetry_virtual_env_bin_path(new_root_dir)
  local pythonPath = poetry_virutalenv_bin .. '/python'
  new_config.settings.python.pythonPath = pythonPath
end

-- formatter settings: { <formatter name> : config }
local formatter_settings_map = {
  black = {
    dynamic_command = get_poetry_bin_cmd_path('black'),
    timeout = 10000
  },
  ruff = {
    dynamic_command = get_poetry_bin_cmd_path('ruff'),
    timeout = 10000
  }
}

-- linter settings: { <linter name> : config }
local linter_settings_map = {
  ruff = {
    dynamic_command = get_poetry_bin_cmd_path('ruff'),
    timeout = 10000
  },
  mypy = {
    dynamic_command = get_poetry_bin_cmd_path('mypy'),
    timeout = 10000
  }
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
  pyright = {
    on_new_config = on_new_config
  }
}
--------------------------------------------------------

-- Imports
local mason = require("mason")
local lspconfig = require('lspconfig')
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
