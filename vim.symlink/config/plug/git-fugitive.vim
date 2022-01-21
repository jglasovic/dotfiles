function! s:ToggleDiff()
  let closed_buf_len = CloseBuffers('fugitive:')
  if closed_buf_len == 0
    exec "Gvdiffsplit!"
  endif
endfunction

function! s:ToggleBlame()
  let closed_buf_len = CloseBuffers('fugitiveblame')
  if closed_buf_len == 0
      exec "G blame"
  endif
endfunction

function! s:ToggleG()
  let closed_buf_len = CloseBuffers('.git/index')
  if closed_buf_len == 0
      exec "G"
  endif
endfunction

nnoremap <leader>gs :call <SID>ToggleG()<CR>
nnoremap <leader>gb :call <SID>ToggleBlame()<CR>
nnoremap <leader>gd :call <SID>ToggleDiff()<CR>
nnoremap <leader>g<left> :diffget //2<CR>
nnoremap <leader>g<right> :diffget //3<CR>
