set nobackup
set nowritebackup
set cmdheight=2
set updatetime=300
set shortmess+=c
set signcolumn=number


let g:coc_global_extensions = [
  \ 'coc-tsserver',
  \ 'coc-json',
  \ 'coc-css',
  \ 'coc-eslint',
  \ 'coc-prettier',
  \ 'coc-pyright'
  \ ]


""" Coc -  Mappings  {{{
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
inoremap <silent><expr> <c-space> coc#refresh()
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gt <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>f  <Plug>(coc-fix-current)
nmap <leader>'  <Plug>(coc-codeaction-cursor)
nnoremap <silent> K :call <SID>show_documentation()<CR>
nnoremap <leader>[ :CocRestart<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

"}}}

autocmd CursorHold * silent call CocActionAsync('highlight')
augroup mygroup
  autocmd!
  autocmd FileType * setl formatexpr=CocAction('formatSelected')
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

command! -nargs=0 Format :call CocAction('format')
command! -nargs=? Fold :call     CocAction('fold', <f-args>)
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

""" Prettier
command! -nargs=0 Prettier :CocCommand prettier.formatFile

""" Pyright
autocmd FileType python let b:coc_root_patterns = ['.git', '.env', 'venv', '.venv', 'setup.cfg', 'setup.py', 'pyproject.toml', 'pyrightconfig.json']
autocmd BufWritePre * :silent call CocAction('runCommand', 'editor.action.organizeImport')

""" Custom auto config for workspace

"function SetCocPythonConfig()
"  let current_buffer_path = expand("%:p")
"
"  for w_path in g:WorkspaceFolders
"    if stridx(current_buffer_path, w_path) >= 0
"      if !exists("g:activeWorkspace") || g:activeWorkspace != w_path
"        let r_pylintrc = findfile(".pylintrc", w_path)
"        execute "redraw!"
"        let r_pyproject = findfile("pyproject.toml", w_path)
"        execute "redraw!"
"
"        if r_pylintrc
"          let pylintrc_path = w_path . '/' . r_pylintrc
"          coc#config("python.linting.pylintArgs",
"            ["--rcfile", pylintrc_path]
"          )
"        endif
"        if r_pyproject
"          let pyproject_path = w_path . '/' . r_pyproject
"          coc#config("python.formatting.blackArgs",
"            ["--config", pyproject_path]
"          )
"
"          coc#config("python.sortImports.args",
"            ["--settings-path", pyproject_path]
"          )
"        endif
"
"        let g:activeWorkspace = w_path
"      endif
"    endif
"  endfor
"
"endfunction
"
"
"augroup coc_python_workspace_config_autocmd
"    au!
"    au WinEnter,BufWinEnter *.py call SetCocPythonConfig()
"augroup END
