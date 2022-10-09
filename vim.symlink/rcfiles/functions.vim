function! HasBuffer(pattern)
  let blist = getbufinfo()
  for buffer in blist
    if(match(buffer.name, a:pattern) > -1)
      return 1
    endif
  endfor
  return 0
endfunction


function! FindBuffers(patterns)
  let blist = getbufinfo()
  let filtered = []
  for buffer in blist
    for pattern in a:patterns
      if(match(buffer.name, pattern) > -1)
        let filtered = add(filtered, buffer)
        break
      endif
    endfor
  endfor
  return filtered
endfunction

function! CloseBuffersByFiletype(filetypes)
  let buffers = getbufinfo()
  for buffer in buffers
    let bufnr = get(buffer,'bufnr',0)
    if bufnr > 0
      let bufFiletype = getbufvar(bufnr, '&filetype')
      for ft in a:filetypes
        if ft == bufFiletype
          try
            silent exec 'bwipeout!' buffer.name
            break
          catch 
            silent echo "Error deleting bufname: ".buffer.name
            break
          endtry
        endif
      endfor
    endif
  endfor
endfunction


function! CloseBuffers(patterns, ...)
  let close_only_first = a:0 || 0
  let buffers = FindBuffers(a:patterns)
  let buflen = len(buffers)
  for buffer in buffers
    let bufnr = get(buffer,'bufnr',0)
    if bufnr > 0
      try
        silent exec 'bwipeout!' buffer.name
      catch 
        silent echo "Error deleting bufname: ".buffer.name
        continue
      endtry
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
