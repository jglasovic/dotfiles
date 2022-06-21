local fmt = string.format
local match = string.match

-- small and fast my custom statusline written in lua
-- one day going to extract this into a separate repo as plugin
local statusline = require('custom-statusline')

-- transparent background
vim.g['onedark_color_overrides'] = {
  background = { gui = "NONE", cterm = "NONE", cterm16 = "NONE" }
}
-- vim.opt.termguicolors = true
vim.cmd'colorscheme onedark'
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

vim.cmd('hi CursorLineNr ctermfg='..colors.purple.cterm..' guifg='..colors.purple.gui)

local function mix_color(fgcolor, bgcolor)
  local mix = {}
  mix.guibg = bgcolor.gui
  mix.ctermbg = bgcolor.cterm
  mix.guifg = fgcolor.gui
  mix.ctermfg = fgcolor.cterm
  return mix
end

local mode_mapping = {
  normal = mix_color(colors.black, colors.green),
  insert = mix_color(colors.black, colors.blue),
  replace = mix_color(colors.black, colors.cyan),
  visual = mix_color(colors.black, colors.purple),
  command = mix_color(colors.black, colors.red)
 }

local bufferline_mapping = {
  active = mix_color(colors.black, colors.green),
  active_modified = mix_color(colors.black, colors.blue),
  inactive = mix_color(colors.green, colors.cursor_grey),
  inactive_modified = mix_color(colors.blue, colors.cursor_grey)
 }

---------- SECTION
local display_filetype_exec = function()
  local js_types = {
    javascript=true,
    typescript=true,
    javascriptreact=true,
    typescriptreact=true
  }
  local ft = vim.bo.filetype
  local content = ''
  if ft == 'python' then
    local pyenv = vim.fn['poetv#statusline']()
    if pyenv and pyenv ~= '' then
      content = M.get_colored_section('green', 'venv: '..pyenv)
    end
  elseif js_types[ft] then
    local node_v_str = match(os.getenv('NVM_BIN'), 'node/.*v[0-9].*[0-9]')
    if node_v_str and node_v_str ~= '' then
      content = M.get_colored_section('green', string.gsub(node_v_str, '/', ':', 1))
    end
  end
  if content ~= '' then
    return ' '..content..' '
  end
  return content
end

local function display_filetype()
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
    s1=mix_color(colors.white, colors.cursor_grey),
    s2=mix_color(colors.white, colors.menu_grey),
    s3=mix_color(colors.white, colors.comment_grey),
    inactive = mix_color(colors.white,colors.comment_grey),
    red = mix_color(colors.red, colors.cursor_grey),
    green = mix_color(colors.green, colors.cursor_grey),
    blue = mix_color(colors.blue, colors.cursor_grey),
    yellow = mix_color(colors.yellow, colors.cursor_grey)
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
  display_filetype_exec(),
  {s2 = display_filetype },
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

