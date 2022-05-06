local lspconfig = require 'lspconfig'
local null_ls = require 'null-ls'

vim.lsp.set_log_level("debug")

local ensure_installed = { "tsserver", "pyright", "sumneko_lua" }

-- https://www.reddit.com/r/neovim/comments/ru871v/comment/hqxquvl/?utm_source=share&utm_medium=web2x&context=3
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  float = { border = "single" },
})



local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<leader>\'', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  -- buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  -- buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  -- buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  -- buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()--<CR>', opts)
  buf_set_keymap("n", '<leader>f', "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end


local get_tsserver_opts = function()
  local on_attach_custom=function(client, bufnr)
    client.resolved_capabilities.document_formatting = false
    return on_attach(client, bufnr)
  end
  return {
    on_attach = on_attach_custom,
    root_dir = lspconfig.util.root_pattern("yarn.lock", "lerna.json", ".git"),
    settings = { documentFormatting = false }
  }
end

local get_pyright_opts = function()
  return {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "workspace",
          useLibraryCodeForTypes = true
        },
        organizeImports = {
          provider = "isort"
        }
      }
    },
    single_file_support = true,
    on_attach = on_attach,
  }
end

local get_lua_opts = function()
  return {
    on_attach = on_attach,
    settings = {
      Lua = {
        diagnostics = {
          -- globals = {"vim"}
        }
      }
    }
  }
end

local get_opts_for_server = function(server)
  local opts = {}
  if server.name == "tsserver" then
    opts = get_tsserver_opts()
  elseif server.name == "sumneko_lua" then
     opts = get_lua_opts()
  elseif server.name == "pyright" then
    opts = get_pyright_opts()
  end
  return opts
end



for _, lsp in pairs(ensure_installed) do
  local opts = get_opts_for_server(lsp)
  lspconfig[lsp].setup(opts)
end

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.eslint_d, -- requires `npm i -g eslint_d`
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.isort,
    null_ls.builtins.diagnostics.mypy,
    null_ls.builtins.diagnostics.pylint
  },
  on_attach = on_attach
})
