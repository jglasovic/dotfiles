local lualine = require('lualine')

local vim_file_exec_info = [[
  let js_filetypes = [
    \ 'javascript',
    \ 'typescript',
    \ 'javascriptreact',
    \ 'typescriptreact'
    \ ]

  if &filetype == 'python'
    let py_venv = poetv#statusline()
    echo py_venv != '' ? 'venv: ' . py_venv : ''
  elseif index(js_filetypes, &filetype) >= 0
    let node_v_str = matchstr($NVM_BIN, 'node\/.*v[0-9\.]*')
    echo substitute(node_v_str, '/', ': ', '')
  endif
]]

local display_exec = function()
  return vim.api.nvim_exec(vim_file_exec_info, true)
end

local diagnostics = {
  'diagnostics',
  sources = { 'coc' },
  symbols = {
    error = ' E ',
    warn = ' W ',
    info = ' I ',
    hint = '   '
  },
  sections = { 'error', 'warn', 'info', 'hint' },
  colored = true,
  diagnostics_color = {
    error = { fg = 'red' },
    warn  = { fg = 'yellow' },
    info  = { fg = 'green' },
    hint  = { fg = 'cyan' }
  }
}


lualine.setup({
  extensions = {'nerdtree','fugitive'},
  options = {
    icons_enabled = true,
    theme = 'powerline_dark',
    component_separators = { '', ' ' },
    section_separators = { '', '' }
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = {{ 'branch', color = { fg = 251 }}},
    lualine_c = { 'diff', 'filename' },
    lualine_x = {
      diagnostics,
      'progress',
    },
    lualine_y = { 'filetype', { display_exec, color = { fg = 'green' } } },
    lualine_z = { 'location' }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {{ 'filename', color = { fg = 251 }}},
    lualine_x = {{ 'location', color = { fg = 251 }}},
    lualine_y = {},
    lualine_z = {}
  },
})
