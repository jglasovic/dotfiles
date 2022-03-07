local fmt = string.format

local function trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

M = {}


----------- SECTIONS AND HIGHLIGHTS -------------
M.modes = {
  [''] = {text = 'S-BLOCK', state = 'visual'},
  [''] = {text = 'V-BLOCK', state = 'visual'},
  ['?'] = {text = '???', state = 'inactive'},
  ['R'] = {text = 'REPLACE', state = 'replace'},
  ['S'] = {text = 'S-LINE', state = 'visual'},
  ['V'] = {text = 'V-LINE', state = 'visual'},
  ['c'] = {text = 'COMMAND', state = 'command'},
  ['i'] = {text = 'INSERT', state = 'insert'},
  ['n'] = {text = 'NORMAL', state = 'normal'},
  ['r'] = {text = 'PROMPT', state = 'replace'},
  ['s'] = {text = 'SELECT', state = 'visual'},
  ['t'] = {text = 'TERMINAL', state = 'command'},
  ['v'] = {text = 'VISUAL', state = 'visual'},
}

M.get_colored_section = function(hlgroup, content)
  if hlgroup == "mode" then
    local mode = M.modes[vim.fn.mode()] or M.modes['?']
    hlgroup = mode.state
  end
  if M.hl_groups and M.hl_groups[hlgroup] then
    return '%#'..M.hl_groups[hlgroup]..'#'..content..'%*'
  end
  return content
end

local function set_hlgroups()
  if not M.hlgroups_table then
    return
  end
  local hl_groups = {}
  for basename_name, group in pairs(M.hlgroups_table) do
    for section, col_g in pairs(group) do
      local hl_group = 'custom_sl_'..basename_name..'_'..section
      if vim.fn.hlexists(hl_group) == 0 then
        local color_str = ''
        for k,v in pairs(col_g) do
           color_str = color_str..fmt('%s=%s ',k,v)
        end
        vim.cmd(fmt('autocmd VimEnter,ColorScheme * hi %s %s', hl_group, color_str))
      end
      hl_groups[section]=hl_group
    end
  end
  M.hl_groups = hl_groups
end



----------- BUFFERLINE -------------


local function is_excluded(bufnr)
  local excluded = true
  excluded = excluded and vim.fn.buflisted(bufnr) == 0
  excluded = excluded or vim.fn.getbufvar(bufnr, '&filetype') == 'qf'
  excluded = excluded or vim.fn.getbufvar(bufnr, '&buftype') == 'terminal'
  return excluded
end

local function get_head(path, tail)
  local result = vim.fn.fnamemodify(path, ':p')
  for _ = 1, #vim.split(tail, '/') do
    result = vim.fn.fnamemodify(result, ':h')
  end
  return vim.fn.fnamemodify(result, ':t')
end

local function unique_tail(buffers)
  local hist = {}
  local duplicate = false
  for _, buffer in ipairs(buffers) do
    if not hist[buffer.name] then
      hist[buffer.name] = 1
    elseif buffer.name ~= '' then
      hist[buffer.name] = hist[buffer.name] + 1
    end
    duplicate = duplicate or hist[buffer.name] > 1
  end
  if not duplicate then
    return
  end
  for _, buffer in ipairs(buffers) do
    if hist[buffer.name] > 1 then
      local parent = get_head(vim.fn.bufname(buffer.bufnr), buffer.name)
      buffer.name = fmt('%s/%s', parent, buffer.name)
    end
  end
  unique_tail(buffers)
end

local function get_buffers()
  local buffers = {}
  for nr = 1, vim.fn.bufnr('$') do
    if not is_excluded(nr) then
      table.insert(buffers, {
        bufnr = nr,
        name = vim.fn.fnamemodify(vim.fn.bufname(nr), ':t'),
        current = nr == vim.fn.bufnr('%'),
        flags = {
          modified = vim.fn.getbufvar(nr, '&modified') == 1,
          modifiable = vim.fn.getbufvar(nr, '&modifiable') == 1,
          readonly = vim.fn.getbufvar(nr, '&readonly') == 1,
        },
      })
    end
  end
  unique_tail(buffers)
  return buffers
end

local function to_section(buffer, idx)
  local flags = {}
  local item = buffer.name == '' and '[No Name]' or buffer.name
  if buffer.flags.modified then
    table.insert(flags, '[+]')
  end
  if not buffer.flags.modifiable then
    table.insert(flags, '[-]')
  end
  if buffer.flags.readonly then
    table.insert(flags, '[RO]')
  end
  flags = table.concat(flags)
  item = flags == '' and item or fmt('%s %s', item, flags)
  item = fmt(' %s ', item)
  return {
    item = item,
    modified = buffer.flags.modified,
    current = buffer.current,
  }
end

M.update_bufferline = function ()
  local sections = {}
  local buffers = get_buffers()
  for i, buffer in ipairs(buffers) do
    local section = to_section(buffer,i)
    table.insert(sections, section)
  end
  local tabline = ''
  for _, section in ipairs(sections) do
    local hlgroup = 'inactive'
    if section.current then
      hlgroup = 'active'
    end
    if section.modified then
      hlgroup = hlgroup..'_modified'
    end
    tabline=tabline..M.get_colored_section(hlgroup, section.item)
  end
  return tabline
end


local function set_bufferline()
  vim.opt.showtabline = 2
  vim.opt.tabline = [[%!luaeval('require("custom-statusline").update_bufferline()')]]
end

----------- STATUSLINE -------------
local function build_statusline(sections)
  local statusline = ''
  for _, v in ipairs(sections) do
    if type(v) == "string" then
      if v ~= '' then
        statusline=statusline..v
      end
    end
    if type(v) == "table" then
      for hlgroup, value in pairs(v) do
        if type(value) == "string" then
          local content = trim(value)
          if content ~= '' then
            statusline = statusline..M.get_colored_section(hlgroup,' '..content..' ')
          end
        end
        if type(value) == "function" then
          local content = value()
          content = (content and trim(content)) or ''
          if content ~= '' then
            statusline = statusline..M.get_colored_section(hlgroup,' '..content..' ')
          end
        end
      end
    end
  end
  return statusline
end

M.update_statusline = function(is_active)
    if is_active then
      return build_statusline(M.statusline_active_sections)
    end
    return build_statusline(M.statusline_inactive_sections)
end



local function set_statusline()
  vim.opt.showmode = false
  vim.opt.statusline = [[%{%luaeval('require("custom-statusline").update_statusline(true)')%}]]
  vim.cmd([[
  augroup hardline
    autocmd!
    autocmd WinEnter,BufEnter * setlocal statusline=%{%luaeval('require(\"custom-statusline\").update_statusline(true)')%}
    autocmd WinLeave,BufLeave * setlocal statusline=%{%luaeval('require(\"custom-statusline\").update_statusline(false)')%}
  augroup END
  ]])
end


-------- SETUP----
M.setup = function (options)
  M.statusline_active_sections = options.statusline_active_sections
  M.statusline_inactive_sections = options.statusline_inactive_sections
  M.hlgroups_table = options.hlgroups_table
  set_hlgroups()
  set_statusline()
  set_bufferline()
end


return M
