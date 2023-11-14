function! DiagnosticsInfo()
  if has('nvim') && luaeval("pcall(GetDiagnosticsStatus)")
      return ' '.luaeval("GetDiagnosticsStatus()").' '
  endif
  return ''
endfunction

function! DebugStatus()
  if has('nvim') && luaeval("pcall(require, 'dap')")
    let status = luaeval("require 'dap'.status()")
    if status != ''
      return '%2* '.status.' %*'
    endif
  endif
  return ''
endfunction

function! VenvName()
  if has('nvim') && luaeval("pcall(require, 'venv-lsp')")
      return ' '.luaeval("require 'venv-lsp'.active_virtualenv()").' '
  endif
  return ''
endfunction

function! GitInfo()
  let s:branch = FugitiveHead()
  if s:branch != ''
    return '['.s:branch.']'
  end
  return ''
endfunction


" Setup colorscheme, statusline, cursorline
set background=dark
let g:onedark_color_overrides = { "background": { "gui": "NONE", "cterm": "NONE", "cterm16": "NONE" }}
colorscheme onedark
hi! link CursorLineNr Keyword
hi! link User1 Cursor 
hi! link User2 Search
hi! link User3 MatchParen
hi! StatusLineNC ctermfg=59 guifg=#5c6370 ctermbg=236 guibg=#2c323c

if has("statusline") && !&cp
  set laststatus=2                        " always show the status bar
  set statusline=%1*\ %t%m%r\ %*          " filename, modified, readonly
  set statusline+=\ %{GitInfo()}          " branch
  set statusline+=%=                      " left-right separation point
  set statusline+=\ %{%DebugStatus()%}    " debugger status
  set statusline+=\ %{DiagnosticsInfo()}         " diagnostics
  set statusline+=\ %{VenvName()}         " diagnostics
  set statusline+=\%y\                    " filetype
  set statusline+=%1*\ %v:%l/%L[%p%%]\%*  " current column : current line/total lines [percentage]
endif

set showmode
set showtabline=2
set tabline=%3*\ %t%m%r\ %*
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


