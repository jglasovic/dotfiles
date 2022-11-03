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
  \ 'coc-spell-checker'
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
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

function! s:show_man_documentation()
  if index(['vim', 'help'], &filetype) >= 0
    execute 'h ' . expand('<cword>')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" show diagnostics, otherwise documentation, on hold
function! s:show_doc_if_no_diagnostic(timer_id)
  if (CocAction('hasProvider','hover'))
    if (coc#float#has_float() == 0)
      silent call CocActionAsync('doHover')
    endif
  endif
endfunction

function! s:show_hover_doc()
  if get(g:, 'coc_service_initialized', 0)
    call timer_start(500, 's:show_doc_if_no_diagnostic')
  endif
endfunction

" autocmd CursorHoldI * :call <sid>show_hover_doc()
" autocmd CursorHold * :call <sid>show_hover_doc()
autocmd CursorHold * silent! call CocActionAsync('highlight')
augroup coc_group
  autocmd!
  autocmd FileType * setl formatexpr=CocAction('formatSelected')
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

command! -nargs=0 Format  :call CocAction('format')
command! -nargs=? Fold    :call CocAction('fold', <f-args>)
command! -nargs=0 OR      :call CocAction('runCommand', 'editor.action.organizeImport')
""" Prettier
command! -nargs=0 Prettier :CocCommand prettier.formatFile

""" Pyright
autocmd FileType python let b:coc_root_patterns = [
      \ '.git',
      \ '.env',
      \ 'venv',
      \ '.venv',
      \ 'setup.cfg',
      \ 'setup.py',
      \ 'pyproject.tml',
      \ 'pyrightconfig.json'
      \ ]

" diagnostics
nmap <silent>[g <Plug>(coc-diagnostic-prev)
nmap <silent>]g <Plug>(coc-diagnostic-next)
" goto
nmap <silent>gd <Plug>(coc-definition)
nmap <silent>gt <Plug>(coc-type-definition)
nmap <silent>gi <Plug>(coc-implementation)
nmap <silent>gr <Plug>(coc-references)
" rename
nmap <leader>rn <Plug>(coc-rename)
" show documentation
nnoremap <silent> K :call <SID>show_documentation()<CR>
nnoremap <silent> M :call <SID>show_man_documentation()<CR>
" code-action
nmap <leader>ab  <Plug>(coc-codeaction)
nmap <leader>.  <Plug>(coc-codeaction-cursor)
" autofix on the current line
nmap <leader>qf  <Plug>(coc-fix-current)
" code lens on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)
" restart coc
nnoremap <leader>[ :CocRestart<CR>
" show diagnostics
nnoremap <leader>, :CocDiagnostics<CR>

command! -nargs=0 RestartDiagnostics  :CocRestart

