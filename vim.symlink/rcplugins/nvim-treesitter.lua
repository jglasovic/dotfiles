require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "bash",
    "graphql",
    "html",
    "javascript",
    "json",
    "python",
    "typescript",
    "yaml",
    "lua",
    "tsx"
  },
  highlight = {
    enable = true
  },
  incremental_selection = {
    enable = true
  },
  textobjects = {
    enable = true
  }
}
