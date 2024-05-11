function! s:toggle_git_status()
  let closed_buf_len = utils#close_buffers_by_filetype(['fugitive'])
  if closed_buf_len == 0
    Git
  endif
endfunction

function! s:toggle_git_blame()
  let closed_buf_len = utils#close_buffers_by_filetype(['fugitiveblame'])
  if closed_buf_len == 0
    Git blame
  endif
endfunction

function! s:toggle_git_diff_buffer()
  let closed_buf_len = utils#close_buffers_by_variables({'fugitive_type':'blob'})
  if closed_buf_len == 0
    Gvdiffsplit!
  endif
endfunction

" same as fzf-git mappings
nnoremap <silent> <leader>gf :GFiles?<CR>
nnoremap <silent> <leader>gc :Commits<CR>
"
nnoremap <silent><leader>gg :call <SID>toggle_git_status()<CR>
nnoremap <silent><leader>gb :call <SID>toggle_git_blame()<CR>
nnoremap <silent><leader>gd :call <SID>toggle_git_diff_buffer()<CR>
nnoremap <silent><leader>gh :diffget //2<CR>
nnoremap <silent><leader>gl :diffget //3<CR>
nnoremap <silent><leader>gy v:GBrowse!<CR>
vnoremap <silent><leader>gy :GBrowse!<CR>
