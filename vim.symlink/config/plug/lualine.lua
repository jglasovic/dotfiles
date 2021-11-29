local lualine = require('lualine')
lualine.setup({
  options = {
    icons_enabled = true,
    theme = 'powerline_dark',
    component_separators = { '', ' ' },
    section_separators = { '', '' }
  },
  sections = {
    lualine_a = { 'mode', {'poetv#statusline', color = {bg = '#cc33ff', fg= '#0A0A0A'}}  },
    lualine_b = { 'FugitiveHead', 'hunks' },
    lualine_c = { 'filename' },
    lualine_x = {
      {
        'diagnostics',
        sources = { 'coc' },
        symbols = {
          error = ' E ',
          warn = ' W ',
          info = ' I ',
          hint = '   ',
        },
        sections = { 'error', 'warn', 'info', 'hint' },
      },
      'progress',
    },
    lualine_y = { 'filetype' },
    lualine_z = { 'location' }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
})

