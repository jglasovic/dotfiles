function! BufSel(pattern)
  let blist = getbufinfo()
  for buffer in blist
    if(match(buffer.name, a:pattern) > -1)
      return buffer
    endif
  endfor
  return {}
endfunction

function! CloseBuf(pattern)
  let buf = s:BufSel(a:pattern)
  let bufnr = get(buf,'bufnr',0)
  if bufnr > 0
    silent exec 'bwipeout!' buf.name
  endif
  return bufnr
endfunction

function! ToggleSpellchecking()
  set spell!
endfunction

function! ToggleLineNumbers()
  set number!
  set relativenumber!
endfunction
