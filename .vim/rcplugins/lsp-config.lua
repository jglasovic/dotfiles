local auto_enable_language_servers = {
  "bashls",
  "lua_ls",
  "jsonls",
  "vimls",
  "intelephense",
  "gopls",
  "ts_ls",
  "regal",
  "rust_analyzer",
  "pyright",
  "vue_ls",
  -- 'pyrefly'
  -- 'basepyright'
}

-- auto venv detection for python language servers
require("venv-lsp").setup()

vim.lsp.config("regal", {
  root_markers = { ".git" },
})

vim.lsp.config("denols", {
  root_markers = { "deno.json", "deno.jsonc" },
})
vim.lsp.config("ts_ls", {
  filetypes = { unpack(vim.lsp.config.ts_ls.filetypes), "vue" },
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = vim.fn.stdpath("data")
            .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
        languages = { "vue" },
        configNamespace = "typescript",
      },
    },
  },
})

-- enable
vim.lsp.enable(auto_enable_language_servers)
