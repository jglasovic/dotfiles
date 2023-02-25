let g:coc_global_extensions = [
  \ 'coc-tsserver',
  \ 'coc-json',
  \ 'coc-css',
  \ 'coc-eslint',
  \ 'coc-prettier',
  \ 'coc-pyright',
  \ 'coc-vimlsp',
  \ '@yaegassy/coc-intelephense',
  \ 'coc-lua',
  \ 'coc-rust-analyzer',
  \ 'coc-go',
  \ 'coc-db'
  \ ]

function! s:check_backspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ <SID>check_backspace() ? "\<Tab>" :
      \ coc#refresh()

inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

function! s:show_documentation()
  if CocAction('hasProvider', 'hover') && CocAction('doHover')
  elseif index(['vim', 'help'], &filetype) >= 0
    execute 'h ' . expand('<cword>')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

augroup coc_group
  autocmd!
  autocmd FileType * setl formatexpr=CocAction('formatSelected')
  autocmd CursorHold * silent! call CocActionAsync('highlight')
augroup end

command! -nargs=0 Format  :call CocAction('format')
command! -nargs=0 OR      :call CocAction('runCommand', 'editor.action.organizeImport')

" """ Pyright
" autocmd FileType python let b:coc_root_patterns = [
"       \ '.git',
"       \ '.env',
"       \ 'venv',
"       \ '.venv',
"       \ 'setup.cfg',
"       \ 'setup.py',
"       \ 'poetry.lock',
"       \ 'pyproject.toml',
"       \ 'pyrightconfig.json'
"       \ ]

function FormatAndSortImports()
  call CocAction('format') 
  call CocAction('runCommand', 'editor.action.organizeImport')
endfunction

" show documentation
nnoremap <silent> K :call <SID>show_documentation()<CR>
" diagnostics
nmap <silent><leader>N <Plug>(coc-diagnostic-prev)
nmap <silent><leader>n <Plug>(coc-diagnostic-next)
" goto
nmap <silent>gd <Plug>(coc-definition)
nmap <silent>gt <Plug>(coc-type-definition)
nmap <silent>gi <Plug>(coc-implementation)
nmap <silent>gr <Plug>(coc-references)

nmap <silent>cr <Plug>(coc-rename)
nmap <leader>cf :call FormatAndSortImports()<CR>
nnoremap <leader>cc :CocRestart<CR>

nmap <leader>.  <Plug>(coc-codeaction-cursor)
nnoremap <leader>, :CocDiagnostics<CR>

command! -nargs=0 RestartDiagnostics  :CocRestart

