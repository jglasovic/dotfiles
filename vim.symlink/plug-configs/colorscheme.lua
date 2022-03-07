local fmt = string.format
local statusline = require('custom-statusline')

-- transparent background
vim.g['onedark_color_overrides'] = {
  background = { gui = "NONE", cterm = "NONE", cterm16 = "NONE" }
}
vim.cmd([[
set termguicolors
colorscheme onedark
]])

-- Get colors defined in colorscheme
local onedark_colors = vim.fn['onedark#GetColors']()
-- map colors from theme
local colors = {
  black = onedark_colors.black,
  blue = onedark_colors.blue,
  cyan = onedark_colors.cyan,
  green = onedark_colors.green,
  comment_grey = onedark_colors.comment_grey,
  cursor_grey = onedark_colors.cursor_grey,
  menu_grey = onedark_colors.menu_grey,
  purple = onedark_colors.purple,
  red = onedark_colors.red,
  white = onedark_colors.white,
  yellow = onedark_colors.yellow
}

local bg_contrast_low = {
  guibg = colors.comment_grey.gui,
  ctermbg = colors.comment_grey.cterm,
}

local bg_contrast_high = {
  guibg = colors.cursor_grey.gui,
  ctermbg = colors.cursor_grey.cterm,
}

local bg_contrast_med = {
  guibg = colors.menu_grey.gui,
  ctermbg = colors.menu_grey.cterm,
}

local mode_mapping = {
  normal = {
    guifg = colors.black.gui,
    guibg = colors.green.gui,
    ctermfg = colors.black.cterm,
    ctermbg = colors.green.cterm,
  },
  insert = {
    guifg = colors.black.gui,
    guibg = colors.blue.gui,
    ctermfg = colors.black.cterm,
    ctermbg = colors.blue.cterm,
  },
  replace = {
    guifg = colors.black.gui,
    guibg = colors.cyan.gui,
    ctermfg = colors.black.cterm,
    ctermbg = colors.cyan.cterm,
  },
  visual = {
    guifg = colors.black.gui,
    guibg = colors.purple.gui,
    ctermfg = colors.black.cterm,
    ctermbg = colors.purple.cterm,
  },
  command = {
    guifg = colors.black.gui,
    guibg = colors.red.gui,
    ctermfg = colors.black.cterm,
    ctermbg = colors.red.cterm,
  },
}

local bufferline_mapping = {
  active = {
    guifg = colors.black.gui,
    guibg = colors.green.gui,
    ctermfg = colors.black.cterm,
    ctermbg = colors.green.cterm,
  },
  active_modified = {
    guifg = colors.black.gui,
    guibg = colors.blue.gui,
    ctermfg = colors.black.cterm,
    ctermbg = colors.blue.cterm,
  },
  inactive = {
    guifg = colors.green.gui,
    guibg = colors.black.gui,
    ctermfg = colors.green.cterm,
    ctermbg = colors.black.cterm,
  },
  inactive_modified = {
    guifg = colors.blue.gui,
    guibg = colors.black.gui,
    ctermfg = colors.blue.cterm,
    ctermbg = colors.black.cterm,
  },
}

local mix_contrast_color = function(contrast, color)
  local mix = {}
  for k,v in pairs(contrast) do mix[k] = v end
  mix.guifg = color.gui
  mix.ctermfg = color.cterm
  return mix
end

---------- SECTION
local display_filetype_exec = function()
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
  local exec = vim.api.nvim_exec(vim_file_exec_info, true)
  if exec and exec ~= '' then
    return vim.bo.filetype..' '..exec
  end
  return vim.bo.filetype
end

local function display_git_branch()
  local branch = vim.fn.FugitiveHead()
  if branch and branch ~= '' then
    return ' ' .. branch
  end
  return ''
end

local function display_git_hunks()
  if not vim.b.gitsigns_status_dict then
    return ''
  end
  local added_num = vim.b.gitsigns_status_dict.added
  local changed_num = vim.b.gitsigns_status_dict.changed
  local removed_num = vim.b.gitsigns_status_dict.removed
  local added = ''
  local changed = ''
  local removed = ''
  if added_num and added_num > 0 then
    added = statusline.get_colored_section('green', '+'..added_num)
  end
  if changed_num and changed_num > 0 then
    changed = statusline.get_colored_section('yellow', '~'..changed_num)
  end
  if removed_num and removed_num > 0 then
    removed = statusline.get_colored_section('red', '-'..removed_num)
  end
  return table.concat({ added, changed, removed }, ' ')
end

local function display_diagnostics()
  local info = vim.b['coc_diagnostic_info']
  if not info then
    return ''
  end
  local errornum = info.error
  local warnnum = info.warning
  local infonum = info.information
  local hintnum = info.hint
  local errorstr = ''
  local warnstr = ''
  local infostr = ''
  local hintstr = ''
  if errornum and errornum > 0 then
    errorstr = statusline.get_colored_section('red', 'E '..errornum)
  end
  if warnnum and warnnum > 0 then
    warnstr = statusline.get_colored_section('yellow', 'W '..warnnum)
  end
  if infonum and infonum > 0 then
    infostr = statusline.get_colored_section('green', 'I '..infonum)
  end
  if hintnum and hintnum > 0 then
    hintstr = statusline.get_colored_section('blue', 'H '..hintnum)
  end
  return table.concat({ errorstr, warnstr, infostr, hintstr }, ' ')
end

local function display_location()
  return '%3l/%L:%-2v'
end

local function display_filename()
  print(vim.g.coc_status)
  local modified = ''
  if vim.bo.modified then
    modified = '[+]'
  elseif not vim.bo.modifiable then
    modified = '[-]'
  end
  return vim.fn.expand('%:t')..modified
end

local function display_mode()
  local mode = statusline.modes[vim.fn.mode()] or M.modes['?']
  local text = mode.text
  if vim.wo.spell then
    text = text..fmt(' SPELL[%s]', string.upper(vim.bo.spelllang))
  end
  return text
end

-- define sections, colors
---------------------------------------
local hlgroups_table = {
  mode = mode_mapping,
  bufferline = bufferline_mapping,
  sections = {
    s1=mix_contrast_color(bg_contrast_high, colors.white),
    s2=mix_contrast_color(bg_contrast_med, colors.white),
    s3=mix_contrast_color(bg_contrast_low, colors.white),
    inactive = mix_contrast_color(bg_contrast_med, colors.white),
    red = mix_contrast_color(bg_contrast_high, colors.red),
    green = mix_contrast_color(bg_contrast_high, colors.green),
    blue = mix_contrast_color(bg_contrast_high, colors.blue),
    yellow = mix_contrast_color(bg_contrast_high, colors.yellow)
  }
}

local statusline_active_sections = {
  {mode = display_mode },
  {s2 = display_git_branch},
  {s1 = display_git_hunks },
  {s1 = display_filename },
  '%<',
  {s1 = '%='},
  {s1 = display_diagnostics },
  {s2 = display_filetype_exec },
  {mode = display_location },
}

local statusline_inactive_sections = {
  {inactive = display_filename},
  '%<',
  {inactive = '%='}
}


statusline.setup({
  statusline_active_sections=statusline_active_sections,
  statusline_inactive_sections=statusline_inactive_sections,
  hlgroups_table=hlgroups_table
})

