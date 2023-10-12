function! s:custom_toggle_dbui()
  call utils#close_buffers_by_name_contains(['dbout'])
  call utils#close_buffers_by_filetype(['sql'])
  DBUIToggle
  let g:db_cache = {}
endfunction

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

let g:db_ui_auto_execute_table_helpers = 1
" let g:omni_sql_default_compl_type = 'syntax'

nmap <leader>db :call <SID>custom_toggle_dbui()<CR>

