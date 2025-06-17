local auto_enable_language_servers = {
  'lua_ls',
  'jsonls',
  'vimls',
  'intelephense',
  'gopls',
  "ts_ls",
  'regal',
  'rust_analyzer',
  'pyright',
  -- 'pyrefly'
  -- 'basepyright'
}

-- auto venv detection for python language servers
require('venv-lsp').setup()

vim.lsp.config('regal', {
  root_markers = { '.git' },
})

vim.lsp.config('denols', {
  root_markers = { "deno.json", "deno.jsonc" },
})

vim.lsp.config('ts_ls', {
  root_markers = { "package.json" },
  single_file_support = false
})

-- enable
vim.lsp.enable(auto_enable_language_servers)
