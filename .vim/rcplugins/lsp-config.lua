local auto_enable_lsp = {
  'pyright',
  'lua_ls',
  'jsonls',
  'vimls',
  'intelephense',
  'gopls',
  "ts_ls",
  'regal',
  'rust_analyzer',
  -- 'pyrefly'
}

-- setup configs for python lsps
local venv_lsp = require('venv-lsp')
venv_lsp.init()

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
vim.lsp.enable(auto_enable_lsp)
