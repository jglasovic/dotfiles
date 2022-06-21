if !has('nvim')
  finish
endif

let g:poetv_executables = ['poetry']

"turning off auto activate and overriding to refresh coc
let g:poetv_auto_activate = 0

function ActivatePoetv()
  let g:CURRENT_VIRTUAL_ENV = $VIRTUAL_ENV

  if &previewwindow != 1 && expand('%:p') !~# "/\\.git/"
    call poetv#activate()
    if g:CURRENT_VIRTUAL_ENV != $VIRTUAL_ENV
      silent exec "RestartDiagnostics"
    endif
  endif
endfunction

augroup poetv_autocmd
    au!
    au WinEnter,BufWinEnter *.py call ActivatePoetv()
augroup END
