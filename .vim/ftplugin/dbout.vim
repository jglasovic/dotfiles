setlocal nowrap
"go to foreign key
noremap <buffer>gd :call db_ui#dbout#jump_to_foreign_table()<CR>

" hack to preserve db connection on forward/backward foreign keys jump
if !exists('g:db_cache')
  let g:db_cache = {}
endif

function! s:cache_db()
  let s:buf_name = expand('%')

  if exists('b:db')
    let s:schema_table = s:get_schema_table_name(b:db)
    let b:table = get(s:schema_table, 1, '')
    let b:schema = ''
    if b:table == '' 
      let b:table = get(s:schema_table, 0, '')
    else
      let b:schema = get(s:schema_table, 0, '')
    endif
    let g:db_cache[s:buf_name] = { 'db': b:db, 'table': b:table, 'schema': b:schema }
  else
    let s:from_cache = get(g:db_cache, s:buf_name, {})
    let b:db = get(s:from_cache, 'db', {})
    let b:table = get(s:from_cache, 'table', '')
    let b:schema = get(s:from_cache, 'schema', '')
  endif
endfunction

function! s:get_schema_table_name(db) abort
  let input = get(a:db, 'input', '')
  if input == ''
    return []
  endif
  let content = join(readfile(input), ' ')
  return split(substitute(matchstr(content, "[Ff][Rr][Oo][Mm]\\s*\\S*"), '"', '', 'g'), '\.\|\ ')[1:]
endfunction

augroup cache_db
  autocmd!
  autocmd BufEnter <buffer> call <SID>cache_db()
augroup end


  
