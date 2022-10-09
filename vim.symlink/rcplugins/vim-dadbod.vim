function! s:custom_toggle_dbui()
  call CloseBuffers(['dbout'])
  call CloseBuffersByFiletype(['sql'])
  DBUIToggle
endfunction


" Toggle db client
nmap <leader>db :call <SID>custom_toggle_dbui()<CR>

" Override mappings
augroup dbui_mappings
  autocmd!
  autocmd FileType dbui nnoremap <buffer> <C-j> <C-w>j
  autocmd FileType dbui nnoremap <buffer> <C-k> <C-w>k
augroup end

let g:db_ui_auto_execute_table_helpers = 1
let g:dbs = {
\  'acorn_local': $ACORN_LOCAL 
\ }
