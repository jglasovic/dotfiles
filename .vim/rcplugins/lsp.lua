local lspconfig = require('lspconfig')
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local cmp = require('cmp')

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    severity_sort = true,
    float = { border = "single" },
  })

vim.keymap.set('n', '<leader>N', vim.diagnostic.goto_prev)
vim.keymap.set('n', '<leader>n', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>,', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'M', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'cr', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>.', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>cf', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

cmp.setup {
  mapping = cmp.mapping.preset.insert({
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' }
  },
}

  -- "black-formatter.args": ["--config", "${workspaceFolder}/pyproject.toml"],
  -- "black-formatter.importStrategy": "fromEnvironment",
  -- "isort.args": ["--settings-path", "${workspaceFolder}/pyproject.toml"],
  -- "isort.importStrategy": "fromEnvironment",
  -- "pylint.args": ["--rcfile", "${workspaceFolder}/.pylintrc"],
  -- "pylint.importStrategy": "fromEnvironment",
local null_ls = require("null-ls")
null_ls.setup({ debug = true,
    sources = {
        null_ls.builtins.diagnostics.pylint.with({
            extra_args = { "--rcfile", "$ROOT/.pylintrc"}
        }),
        null_ls.builtins.formatting.isort.with({
            extra_args = { "--settings-path", "$ROOT/pyproject.toml"}
        }),
        null_ls.builtins.formatting.black.with({
            extra_args = { "--config", "$ROOT/pyproject.toml"}
        }),
    },
})
vim.api.nvim_create_user_command('RestartDiagnostics', 'LspRestart', {})
lspconfig.pyright.setup({capabilities = capabilities })


