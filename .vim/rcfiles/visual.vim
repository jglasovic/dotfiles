if has('nvim')
lua << EOF
  function DiagnosticsInfo()
    local result, status = pcall(GetDiagnosticsStatus)
    if not result then
      return ''
    end
    return ' '..status..' '
  end

  function DebugStatus()
    local result, dap = pcall(require, 'dap')
    if not result then 
      return ''
    end
    local status = dap.status()
    if status == '' then
      return ''
    end
    return '%2* '..status..' %*'
  end

  function VenvName()
    local result, venv = pcall(require, 'venv-lsp')
    if not result then
      return ''
    end
    local venv_name = venv.active_virtualenv()
    if not venv_name then
      return ''
    end
    return ' '..venv_name..' '
  end

  function GhPRNumber(branch)
    local success, pr_number = pcall(GetGhPrNumber, branch) 
    if not success or pr_number == '' then
      return ''
    end
    return '[#'..pr_number..']'
  end
EOF
endif

function! GitInfo()
  let branch = FugitiveHead()
  let values = []
  if branch != ''
    call add(values, '['.branch.']')
  endif

  if has('nvim')
    let pr_number = v:lua.GhPRNumber(branch)
    call add(values, pr_number)
  endif
  return join(values, '')
endfunction

" Setup colorscheme, statusline, cursorline
set background=dark
set notermguicolors
let g:onedark_color_overrides = { "background": { "gui": "NONE", "cterm": "NONE", "cterm16": "NONE" }}
colorscheme onedark
hi! link CursorLineNr Keyword
hi! link User1 Cursor 
hi! link User2 Search
hi! link User3 MatchParen
hi! StatusLineNC ctermfg=59 guifg=#5c6370 ctermbg=236 guibg=#2c323c
hi! link LspInfoBorder NormalFloat

if has("statusline") && !&cp
  set laststatus=2                        " always show the status bar
  set statusline=%1*\ %t%m%r\ %*          " filename, modified, readonly
  set statusline+=\ %{GitInfo()}          " branch
  set statusline+=%=                      " left-right separation point
  if has('nvim')
    set statusline+=\ %{%v:lua.DebugStatus()%}    " debugger status
    set statusline+=\ %{v:lua.DiagnosticsInfo()}  " diagnostics
    set statusline+=\ %{v:lua.VenvName()}         " diagnostics
  endif
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
