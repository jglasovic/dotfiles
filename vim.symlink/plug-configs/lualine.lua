local lualine = require('lualine')

-- my custom theme

local colors = {
  black        = '#202020',
  neon         = '#DFFF00',
  white        = '#FFFFFF',
  green        = '#0DBD15',
  seagreen     = '#5FFF87',
  purple       = '#5F005F',
  blue         = '#00DFFF',
  darkblue     = '#00005F',
  darknavyblue = '#00005F',
  navyblue     = '#000080',
  brightgreen  = '#9CFFD3',
  gray         = '#444444',
  darkgray     = '#3c3836',
  lightgray    = '#504945',
  inactivegray = '#7c6f64',
  visiblegray  = '#C6C6C6',
  orange       = '#FFAF00',
  darkred      = '#5F0000',
  brightorange = '#C08A20',
  brightred    = '#AF0000',
  cyan         = '#00DFFF',
  red          = '#FF0000',
  yellow       = '#FFFF00'
}

local theme = {
  normal = {
    a = { bg = colors.green, fg = colors.black, gui="bold" },
    b = { bg = colors.gray, fg = colors.white },
    c = { bg = colors.darknavyblue, fg = colors.seagreen},
    y = { bg = colors.gray, fg = colors.green },

  },
  insert = {
    a = { bg = colors.blue, fg = colors.darkblue, gui="bold" },
    b = { bg = colors.navyblue, fg = colors.white },
    c = { bg = colors.purple, fg = colors.white },
  },
  visual = {
    a = { bg = colors.orange, fg = colors.black, gui="bold" },
    b = { bg = colors.darkgray, fg = colors.white },
    c = { bg = colors.darkred, fg = colors.white },
  },
  replace = {
    a = { bg = colors.brightred, fg = colors.white, gui="bold" },
    b = { bg = colors.cyan, fg = colors.darkblue },
    c = { bg = colors.navyblue, fg = colors.white },
  },
  command = {
    a = { bg = colors.neon, fg = colors.black, gui="bold" },
    b = { bg = colors.darkgray, fg = colors.white },
    c = { bg = colors.darknavyblue, fg = colors.brightgreen },
  },
  inactive = {
    c = { bg = colors.darknavyblue, fg = colors.seagreen },
  },
}

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
    error = { fg = colors.red },
    warn  = { fg = colors.yellow },
    info  = { fg = colors.green },
    hint  = { fg = colors.cyan }
  }
}

local diff = {
  'diff',
  diff_color = {
    added = { fg = colors.green },
    modified = { fg = colors.yellow },
    removed = { fg = colors.red },
  }
}


lualine.setup({
  extensions = {'nerdtree','fugitive', 'fzf'},
  options = {
    icons_enabled = true,
    theme = theme,
    component_separators = {},
    section_separators = {}
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch' },
    lualine_c = { diff, 'filename' },
    lualine_x = {
      diagnostics,
      'progress',
    },
    lualine_y = { 'filetype', { display_exec } },
    lualine_z = { 'location' }
  },
  inactive_sections = {
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
  },
})
