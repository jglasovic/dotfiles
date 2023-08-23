let g:netrw_dirhistmax = 0
let g:netrw_liststyle = 0
let g:netrw_localcopycmdopt=" -r "
let g:netrw_localcopydircmdopt = " -r "
let g:netrw_localmovecmdopt=" -r "
let g:netrw_preview = 1

hi! link netrwMarkFile Search

"open directory of the current buffer with cursor on a position of that buffer
function! s:open_netrw_with_cursor_position()
  let buf_name = expand('%:t')
  Ex
  if buf_name != ''
    call search(buf_name)
  endif
endfunction

nnoremap <leader>e :call <SID>open_netrw_with_cursor_position()<CR>
"open current working directory
nnoremap <Leader>E :Ex $PWD<CR>
