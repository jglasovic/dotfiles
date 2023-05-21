function! s:buffer_label(bn, mod) abort
    let bufname = fnamemodify(bufname(a:bn), a:mod)
    if bufname == ''
      let bufname = '[No Name]'
    endif
    return bufname
endfunction

" define what to exclude
function! s:is_excluded(bn)
  let excluded = 1
  let excluded = excluded && buflisted(a:bn) == 0
  let excluded = excluded || getbufvar(a:bn, '&filetype') == 'qf'
  let excluded = excluded || getbufvar(a:bn, '&buftype') == 'terminal'
  return excluded
endfunction

function! s:get_all_buffers()
  let buflist = []
  for i in range(bufnr('$'))
    if !s:is_excluded(i+1)
      call add(buflist, i+1)
    endif
  endfor
  return buflist
endfunction

" cannot use %m%r for bufferline because it's just showing for the current one
function! s:buff_mod(bn)
  let mod = ''
  if getbufvar(a:bn, '&modified') == 1
    let mod.= '[+]'
  end
  if getbufvar(a:bn, '&modifiable') != 1
    let mod .= '[-]'
  end
  if getbufvar(a:bn, '&readonly') == 1
    let mod .= '[RO]'
  end
  return mod
endfunction

function! DisplayBuffline() abort
  let line = ' '
  let current_bn = bufnr("%")
  let buflist = s:get_all_buffers()
  for bn in buflist
    let line .= (bn == current_bn ? '%#MatchParen#' : '%#TabLine#') " for highlighting
    let line .= ' '
    let line .= s:buffer_label(bn, ':t')                       " filename
    let line .= s:buff_mod(bn)                                 " modified, readonly
    let line .= ' '
  endfor
  let line .= '%#TabLineFill#'
  return line .' ' 
endfunction

function! DiagnosticsInfo()
  let mapping = {
      \ 'error': 'E:',
      \ 'warning': 'W:',
      \ 'information': 'I:',
      \ 'hint': 'H:'
      \ }
  let info = get(b:, 'coc_diagnostic_info', {})
  let status_list = []
  for [key, value] in items(info)
    if !has_key(mapping, key) || value == 0
      continue
    endif
    call add(status_list, mapping[key].value)
  endfor
  return join(status_list, ' ')
endfunction

function! GitInfo()
  let s:branch = FugitiveHead()
  if s:branch != ''
    return ' '.s:branch
  end
  return ''
endfunction

function! DebugStatus()
  if !has('nvim')
    return ''
  endif
  let status = luaeval("require'dap'.status")()
  if status == ''
    return ''
  endif
  return '%2* '.status.' %*'
endfunction
" Setup colorscheme, statusline, tabline, cursorline
set background=dark
let g:onedark_color_overrides = { "background": { "gui": "NONE", "cterm": "NONE", "cterm16": "NONE" }}
colorscheme onedark
hi! link CursorLineNr Keyword
hi! link User1 Cursor 
hi! link User2 Search
hi! StatusLineNC ctermfg=59 guifg=#5c6370 ctermbg=236 guibg=#2c323c

if has("statusline") && !&cp
  set laststatus=2                        " always show the status bar
  set statusline=%1*\ %t%m%r\ %*          " filename, modified, readonly
  set statusline+=\ %{GitInfo()}          " branch
  set statusline+=%=                      " left-right separation point
  set statusline+=\ %{%DebugStatus()%}      " debugger status
  set statusline+=\ %{LSCServerStatus()}  " diagnostics
  set statusline+=\%y\                   " filetype
  set statusline+=%1*\ %v:%l/%L[%p%%]\%* " current column : current line/total lines [percentage]
endif

set showmode
set showtabline=2
set tabline=%!DisplayBuffline()

" cursor / rows
set cursorline
set cursorlineopt=number

function! SetCursorLine()
  let val = &cursorlineopt
  if stridx(val,'line') != -1
    set cursorlineopt=number
  else
    set cursorlineopt=number,line
  endif
endfunction

augroup cursor_line_style
  autocmd!
  " automatically rebalance windows on vim resize
  autocmd VimResized * :wincmd =
  " show cursorline in insert mode
  autocmd InsertEnter,InsertLeave * call SetCursorLine()
augroup END


