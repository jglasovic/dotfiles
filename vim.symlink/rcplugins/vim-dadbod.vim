function! s:custom_toggle_dbui()
  call CloseBuffersByNameContains(['dbout'])
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

" Override Primary Keys helper query
let s:pk_sql = "
      \ SELECT a.attname, format_type(a.atttypid, a.atttypmod) AS data_type\n
      \ FROM   pg_index i\n
      \ JOIN   pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)\n
      \ WHERE  i.indrelid = '{schema}.{table}'::regclass\n
      \ AND    i.indisprimary;"
  
let g:db_ui_table_helpers = {
\   'postgresql': {
\     'Primary Keys': s:pk_sql
\   }
\ }

" Auto exec
let g:db_ui_auto_execute_table_helpers = 1

" Connections
" let g:dbs = {
" \  'acorn_local': $ACORN_LOCAL,
" \  'acorn_sdm_stage_ro': $ACORN_SDM_STAGE_RO
" \ }
