function! s:ToggleDiff()
  let closed_buf_len = CloseBuffers('fugitive:')
  if closed_buf_len == 0
    Gvdiffsplit!
  endif
endfunction

function! s:ToggleBlame()
  let closed_buf_len = CloseBuffers('fugitiveblame')
  if closed_buf_len == 0
    G blame
  endif
endfunction

function! s:ToggleStatus()
  let closed_buf_len = CloseBuffers('.git/index')
  if closed_buf_len == 0
    G
  endif
endfunction

nnoremap <silent><leader>gs :call <SID>ToggleStatus()<CR>
nnoremap <silent><leader>gb :call <SID>ToggleBlame()<CR>
nnoremap <silent><leader>gd :call <SID>ToggleDiff()<CR>
nnoremap <silent>gl :diffget //2<CR>
nnoremap <silent>gh :diffget //3<CR>
