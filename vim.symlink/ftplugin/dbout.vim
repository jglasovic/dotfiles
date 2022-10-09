set nowrap

function! s:move_columns(direction)
  let line = getline('.')
  let [bufnr, lineNr, position, _] = getpos('.')
  set noignorecase
  if a:direction == 'f'
    let part = line[position:len(line) - 1]
    if match(part, '|') > -1
      exe "normal ".a:direction."|"
      normal l
    else
      call cursor(lineNr, len(line) - 1)
    endif
  else
    let part = line[0 : position - 1]
    if match(part, '|') > -1
      exe "normal ".a:direction."|"
      normal h
    else
      call cursor(lineNr, 1)
    endif
  endif
  set ignorecase
endfunction

nnoremap <buffer>w :call <SID>move_columns('f')<CR> 
nnoremap <buffer>b :call <SID>move_columns('F')<CR>
