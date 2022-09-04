local USE_LSP = os.getenv("USE_LSP")
if not USE_LSP or USE_LSP ~= 'true'  then
  return
end

local lspconfig = require 'lspconfig'
local util = require 'lspconfig/util'
local null_ls = require 'null-ls'
local nls_utils = require "null-ls.utils"

vim.lsp.set_log_level("debug")

-- Ensure installed npm packages
-- local npm_ensure_installed = { "pyright", "eslint_d", "typescript-language-server", "typescript" }

-- for _, package in pairs(npm_ensure_installed) do
--   local cmd = "silent !npm list -g " .. package .. " || npm i -g " .. package
--   local result = vim.api.nvim_exec(cmd, true)
-- end
-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- lsp server names
local lsp_servers = { "tsserver", "pyright" }

-- https://www.reddit.com/r/neovim/comments/ru871v/comment/hqxquvl/?utm_source=share&utm_medium=web2x&context=3
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  float = { border = "single" },
})

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[g', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']g', vim.diagnostic.goto_next, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', 'J', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>x', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', '<leader>F', vim.lsp.buf.formatting, bufopts)
end

-- local lsp_flags = {
--   -- This is the default in Nvim 0.7+
--   debounce_text_changes = 150,
-- }


local get_tsserver_opts = function()
  local on_attach_custom=function(client, bufnr)
    client.resolved_capabilities.document_formatting = false
    return on_attach(client, bufnr)
  end
  return {
    on_attach = on_attach_custom,
    root_dir = util.root_pattern("yarn.lock", "lerna.json", ".git"),
    settings = { documentFormatting = false },
    capabilities = capabilities
  }
end

local get_pyright_opts = function()
  return {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_dir = util.root_pattern(".git"),

    -- root_dir = function(fname)
    --   local root_files = {
    --     '.git'
    --     -- , '.env', 'venv', '.venv', 'setup.cfg', 'setup.py', 'pyproject.toml', 'pyrightconfig.json'
    --     -- 'pyproject.toml',
    --     -- 'setup.py',
    --     -- 'setup.cfg',
    --     -- 'requirements.txt',
    --     -- 'Pipfile',
    --     -- 'pyrightconfig.json',
    --   }
    --   return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname) or util.path.dirname(fname)
    -- end,
    settings = {
      python = {
        -- formatting = {
        --   provider = "black",
        --   blackArgs = { "--config", "${workspaceFolder}/pyproject.toml" },
        -- },
        -- linting = { 
        --   lintOnSave = true, 
        --   pylintEnabled = true,
        --   pylintArgs = { "--rcfile", "${workspaceFolder}/.pylintrc" },
        -- },
        -- organizeimports = { provider = "isort" },
        -- sortImports = { 
        --   args = { "--settings-path", "${workspaceFolder}/pyproject.toml" },
        -- },
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "workspace",
          useLibraryCodeForTypes = true
        },
        -- organizeImports = {
        --   provider = "isort"
        -- }
      }
    },
    -- single_file_support = true,
    on_attach = on_attach,
    capabilities = capabilities
  }
end

local get_lua_opts = function()
  return {
    on_attach = on_attach,
    settings = {
      Lua = {
        diagnostics = {
          globals = {"vim"}
        }
      }
    },
    capabilities = capabilities
  }
end

local get_opts_for_server = function(server)
  local M = {}
  if server.name == "tsserver" then
    M = get_tsserver_opts()
  -- elseif server.name == "sumneko_lua" then
  --    opts = get_lua_opts()
  elseif server.name == "pyright" then
    M = get_pyright_opts()
  end
  return M
end



for _, lsp in pairs(lsp_servers) do
  local options = get_opts_for_server(lsp)
  lspconfig[lsp].setup(options)
end

null_ls.setup({
  root_dir = nls_utils.root_pattern ".git",
  sources = {
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.eslint_d,
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.isort,
    -- null_ls.builtins.diagnostics.mypy,
    null_ls.builtins.diagnostics.pylint
  },
  on_attach = on_attach,
  capabilities = capabilities
})

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}
vim.api.nvim_exec([[
 command! -nargs=0 RestartDiagnostics  :LspRestart
]], true)

