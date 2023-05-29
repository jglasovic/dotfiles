require("mason").setup()
local lspconfig = require('lspconfig')
local mason_lsp = require("mason-lspconfig")
local cmp = require('cmp')
local cmp_nvim = require('cmp_nvim_lsp')
local null_ls = require("null-ls")

-- Settings (only modify this)------------------------------

-- Note: everything installed thru mason will automaticly be configured
local ensure_installed = {
  "pyright", "lua_ls", "jsonls", "vimls", "rust_analyzer", "intelephense", "gopls"
}

-- [Optional] server settings: { <server name> : config }
local server_settings_map = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" }
        }
      }
    }
  }
}

-- [Optional] formatter settings: { <formatter name> : config }
local formatter_settings_map = {
  black = {
    extra_args = { "--config", "$ROOT/pyproject.toml" }
  },
  isort = {
    extra_args = { "--settings-path", "$ROOT/pyproject.toml" }
  }
}

-- [Optional] linter settings: { <linter name> : config }
local linter_settings_map = {
  pylint = {
    extra_args = { "--rcfile", "$ROOT/.pylintrc" }
  }
}
--------------------------------------------------------

-- Mappings

local man_documentation = function()
  if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
    return vim.cmd('h ' .. vim.fn.expand('<cword>'))
  end
  if vim.bo.keywordprg ~= '' then
    return vim.cmd('!' .. vim.bo.keywordprg .. ' ' .. vim.fn.expand('<cword>'))
  end
  return print('Missing man documentation!')
end

local toggle_git_workspace = function(file)
  return function()
    -- toggle git root workspace dir
    local workspaces = vim.lsp.buf.list_workspace_folders()
    local git_root_dir = lspconfig.util.find_git_ancestor(file)
    for _, workspace in pairs(workspaces) do
      if workspace == git_root_dir then
        print("Removing workspace: " .. git_root_dir)
        return vim.lsp.buf.remove_workspace_folder(git_root_dir)
      end
    end
    print("Adding workspace: " .. git_root_dir)
    return vim.lsp.buf.add_workspace_folder(git_root_dir)
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
vim.keymap.set('n', '<leader>a,', function()
  vim.diagnostic.setloclist({ workspace = true })
end)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'M', man_documentation, opts)
    vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>cf', format, opts)
    -- workspace
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wA', list_workspaces, opts)
    vim.keymap.set('n', '<leader>wt', toggle_git_workspace(ev.file), opts)
  end,
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

vim.api.nvim_create_autocmd('CursorHold', {
  callback = lsp_diagnostics_popup_handler,
  group = vim.api.nvim_create_augroup('reset_group', {})
})

-- diagnostics display
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  severity_sort = true,
  float = { border = "single", focusable = false },
})

-- completion
local select_in_cmp = function(exec)
  return function(fallback)
    if cmp.visible() then
      exec()
    else
      fallback()
    end
  end
end

local cmp_confirm = {
  behavior = cmp.ConfirmBehavior.Replace,
  select = true,
}

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-u>'] = cmp.mapping.scroll_docs(-3),
    ['<C-d>'] = cmp.mapping.scroll_docs(3),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm(cmp_confirm),
    ['<Tab>'] = cmp.mapping(select_in_cmp(cmp.select_next_item), { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(select_in_cmp(cmp.select_prev_item), { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'buffer' },
    { name = 'path' }
  }, {
    { name = 'buffer' },
  })
})

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'buffer' }
  })
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- LSP config
-- mason setup installed servers
local handlers = {
  -- setup all mason installed servers with default config
  function(server_name)
    lspconfig[server_name].setup({
      capabilities = vim.tbl_deep_extend(
        'force',
        lspconfig.util.default_config.capabilities,
        vim.lsp.protocol.make_client_capabilities(),
        cmp_nvim.default_capabilities()
      )
    })
  end
}
-- apply custom settings per server defined in configs
for server, settings in pairs(server_settings_map) do
  handlers[server] = function()
    lspconfig[server].setup(settings)
  end
end
mason_lsp.setup({ handlers = handlers, ensure_installed = ensure_installed })

local sources = {}
for linter, config in pairs(linter_settings_map) do
  table.insert(sources, null_ls.builtins.diagnostics[linter].with(config))
end
-- formatters
for formatter, config in pairs(formatter_settings_map) do
  table.insert(sources, null_ls.builtins.formatting[formatter].with(config))
end

null_ls.setup({
  debug = true,
  sources = sources
})
