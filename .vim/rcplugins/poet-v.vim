if !has('python3')
  finish
endif

let g:poetv_executables = ['poetry']

"turning off auto activate and overriding to refresh LSP
let g:poetv_auto_activate = 0

" workaround venv activation and lsp restart
function! AsyncRestartLsp(timer_id)
  silent exec "lua vim.diagnostic.reset()"
  silent exec "LspRestart"
endfunction

function s:activate_poetv()
  let g:CURRENT_VIRTUAL_ENV = $VIRTUAL_ENV

  if &previewwindow != 1 && expand('%:p') !~# "/\\.git/"
    call poetv#activate()
    if g:CURRENT_VIRTUAL_ENV != $VIRTUAL_ENV 
      call timer_start(10, 'AsyncRestartLsp')
    endif
  endif
endfunction

augroup poetv_autocmd
    au!
    au WinEnter,BufWinEnter *.py call <SID>activate_poetv()
augroup END
