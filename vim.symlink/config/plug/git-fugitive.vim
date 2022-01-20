function! s:ToggleDiff()
  let bufnr = CloseBuf('fugitive:')
  if (&diff == 0 || getbufvar('#', '&diff') == 0) && bufnr == 0
    exec "Gvdiffsplit!"
  endif
endfunction

function! s:ToggleBlame()
  let bufnr = CloseBuf('fugitiveblame')
  if bufnr == 0
      exec "G blame"
  endif
endfunction

function! s:ToggleG()
  let bufnr = CloseBuf('.git/index')
  if bufnr == 0
      exec "G"
  endif
endfunction

nnoremap <leader>g :call <SID>ToggleG()<CR>
nnoremap <leader>b :call <SID>ToggleBlame()<CR>
nnoremap <leader>d :call <SID>ToggleDiff()<CR>
