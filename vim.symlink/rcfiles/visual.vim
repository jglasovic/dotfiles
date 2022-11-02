
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
    let line .= (bn == current_bn ? '%#Title#' : '%#TabLine#') " for highlighting
    let line .= ' '
    let line .= s:buffer_label(bn, ':t')                               " filename
    let line .= s:buff_mod(bn)                                         " modified, readonly
    let line .= ' '
  endfor
  let line .= '%#TabLineFill#'
  return line .' ' 
endfunction

function! DiagnosticsInfo()
  let s:info = get(b:, 'coc_diagnostic_info', {})
  let error = get(s:info, 'error', 0)
  let warn = get(s:info, 'warning', 0)
  let info = get(s:info, 'information', 0)
  let hint = get(s:info, 'hint', 0)
  return (error ? "E:".error : "").(warn ? " W:".warn : "").(info ? " I:".info : "").(hint ? " H:".hint : "")
endfunction

function! GitInfo()
  let s:branch = FugitiveHead()
    if s:branch != ''
      return ' '.s:branch
    end
    return ''
endfunction

" Setup colorscheme, statusline, tabline, cursorline
set background=dark
let g:onedark_color_overrides = { "background": { "gui": "NONE", "cterm": "NONE", "cterm16": "NONE" }}
colorscheme onedark
hi! link CursorLineNr Keyword
hi! link User1 Cursor 

if has("statusline") && !&cp
  set laststatus=2                          " always show the status bar
  set statusline=%1*
  set statusline+=\ %t                      " filename
  set statusline+=%m%r                      " modified, readonly
  set statusline+=\ %0*
  set statusline+=\ %{GitInfo()}            " branch and hunks
  set statusline+=%=                        " left-right separation point
  set statusline+=\ %{DiagnosticsInfo()}    " diagnostics
  set statusline+=\ %y                        " filetype
  set statusline+=\ %1*
  set statusline+=\ %v:%l/%L[%p%%]          " current column : current line/total lines [percentage]
  set statusline+=%0*
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

augroup style
  autocmd!
  " automatically rebalance windows on vim resize
  autocmd VimResized * :wincmd =
  " show cursorline in insert mode
  autocmd InsertEnter,InsertLeave * call SetCursorLine()
augroup END


