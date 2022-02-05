"lua << EOF
"
"
"  local lspconfig = require 'lspconfig'
"  local configs = require("lspconfig/configs")
"  local lsp_installer = require 'nvim-lsp-installer'--.settings({ log_level = vim.log.levels.DEBUG })
"
"  local on_attach = function(client, bufnr)
"    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
"    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
"    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
"
"    -- Mappings.
"    local opts = { noremap=true, silent=true }
"    buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
"    buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
"    buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
"    buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
"    buf_set_keymap('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
"    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
"    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
"    buf_set_keymap('n', '<leader>\'', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
"    buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
"    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
"    -- buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
"    -- buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
"    -- buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
"    buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
"    buf_set_keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
"    -- buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()--<CR>', opts)
"    buf_set_keymap("n", '<leader>f', "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
"  end
"
"  local get_tsserver_opts = function()
"    local on_attach_custom=function(client, bufnr)
"      client.resolved_capabilities.document_formatting = false
"          --ts_utils_attach(client)
"      return on_attach(client, bufnr)
"    end
"    return {
"      on_attach = on_attach_custom,
"      root_dir = lspconfig.util.root_pattern("yarn.lock", "lerna.json", ".git"),
"      settings = { documentFormatting = false }
"    }
"  end
"
"  local get_efm_opts = function()
"    local prettier = {
"      formatCommand = "./node_modules/.bin/prettier --stdin-filepath ${INPUT}",
"      formatStdin = true,
"      rootMarkers = { ".prettierrc", ".prettierrc.json", ".prettierrc.js" }
"    }
"    local eslint = {
"      lintCommand = "eslint --fix --stdin --stdin-filename ${INPUT}",
"      lintIgnoreExitCode = true,
"      lintStdin = true,
"      lintFormats = { "%f:%l:%c: %m" },
"      rootMarkers = { "package.json" }
"    }
"    local languages = {
"      typescript = { prettier, eslint },
"      javascript = { prettier, eslint },
"      typescriptreact = { prettier, eslint },
"      javascriptreact = { prettier, eslint },
"      yaml = { prettier },
"      json = { prettier },
"      html = { prettier },
"      scss = { prettier },
"      css = { prettier },
"      markdown = { prettier }
"    }
"
"    return {
"      root_dir = lspconfig.util.root_pattern("package.json", ".git"),
"      filetypes = vim.tbl_keys(languages),
"      init_options = { documentFormatting = true, codeAction = true },
"      settings = { languages = languages, log_level = 1, log_file = '~/efm.log' },
"      on_attach = on_attach
"    }
"
"  end
"
"  local setup_server = function(server)
"    local opts = {}
"    -- tsserver config:
"    if server.name == "tsserver" then
"      opts = get_tsserver_opts()
"      -- efm config:
"    elseif server.name == "efm" then
"      opts = get_efm_opts()
"    end
"
"    server:setup(opts)
"  end
"  lsp_installer.on_server_ready(setup_server)
"
"EOF
"
