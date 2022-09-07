function! HasBuffer(pattern)
  let blist = getbufinfo()
  for buffer in blist
    if(match(buffer.name, a:pattern) > -1)
      return 1
    endif
  endfor
  return 0
endfunction


function! FindBuffers(pattern)
  let blist = getbufinfo()
  let filtered = []
  for buffer in blist
    if(match(buffer.name, a:pattern) > -1)
      let filtered = add(filtered, buffer)
    endif
  endfor
  return filtered
endfunction

function! CloseBuffers(pattern, ...)
  let close_only_first = a:0 || 0
  let buffers = FindBuffers(a:pattern)
  let buflen = len(buffers)
  for buffer in buffers
    let bufnr = get(buffer,'bufnr',0)
    if bufnr > 0
      silent exec 'bwipeout!' buffer.name
      if close_only_first
        return buflen
      endif
    endif
  endfor
  return buflen
endfunction

function! ToggleLineNumbers()
  set number!
  set relativenumber!
endfunction

function! SynGroup()
    let l:s = synID(line('.'), col('.'), 1)
    echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfun
