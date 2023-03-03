function! utils#find_buffers(patterns)
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

function! utils#close_buffers_by_filetype(filetypes)
  let buffers = getbufinfo()
  let num_closed = 0
  for buffer in buffers
    let bufnr = get(buffer,'bufnr',0)
    if bufnr <= 0
      continue
    endif
    let bufFiletype = getbufvar(bufnr, '&filetype')
    for ft in a:filetypes
      if ft != bufFiletype
        continue
      endif
      try
        silent exec 'bwipeout!' buffer.name
        let num_closed = num_closed + 1
        break
      catch 
        silent echo "Error deleting bufname: ".buffer.name
        break
      endtry
    endfor
  endfor
  return num_closed
endfunction

function! utils#close_buffers_by_name_contains(patterns, ...)
  let close_only_first = a:0 || 0
  let buffers = utils#find_buffers(a:patterns)
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

function! utils#toggle_line_numbers()
  set number!
  set relativenumber!
endfunction

function! utils#syn_group()
    let l:s = synID(line('.'), col('.'), 1)
    echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfun

function! utils#get_workspace_folders(file_dir)
  let workspace_folders = [] 
  for path in get(g:, 'WorkspaceFolders', [])
    let full_path = expand(path) 
    if stridx(a:file_dir, full_path)
      call add(workspace_folders, full_path)
    endif
  endfor
  return workspace_folders
endfunction

function! utils#get_coc_root_patterns()
  if !exists("*coc#util#root_patterns")
    return []
  endif
  let coc_root_patterns = coc#util#root_patterns()
  return get(coc_root_patterns, 'server', []) + get(coc_root_patterns, 'buffer', []) + get(coc_root_patterns, 'global', [])
endfunction

function! utils#get_project_root_by_patterns(dir_path, patterns, ...) abort
  let opts = get(a:000, 0, {})
  let workspace_folders = get(opts, 'workspace_folders', []) " wanna first check on some known workspace_folders
  let stop_dir_path = get(opts, 'stop_path', expand('$HOME')) " prevent search upwards at specific dir
  let strict = get(opts, 'strict', 0) " throw an error if cannot find dir by patterns, otherwise return cwd

  if len(a:patterns) == 0 || a:dir_path == stop_dir_path
    if strict
      throw "Cannot find root dir by patterns provided"
    endif
    return expand(getcwd())
  endif

  let idx = index(workspace_folders, a:dir_path)
  if idx != -1
    return workspace_folders[idx]
  endif

  for pattern in a:patterns
    let test_pattern_path = a:dir_path . '/' . pattern
    if !empty(glob(test_pattern_path))
      return a:dir_path
    endif
  endfor
  " going upwards one dir 
  let up_dir_path = substitute(a:dir_path,'/[^\/]\+\(?\=\/$\|$\)', '', 'g')
  return utils#get_project_root_by_patterns(up_dir_path, a:patterns, opts)
endfunction

function! utils#test_command_time(com, ...)
  let time = 0.0
  let numberOfTimes = a:0 ? a:1 : 50000
  for i in range(numberOfTimes + 1)
    let t = reltime()
    execute a:com
    let seconds = reltimefloat(reltime(t))
    let time += seconds
    echo i.' / '.numberOfTimes
    redraw
  endfor
  echo 'Average time: '.string(time / numberOfTimes)
endfunction
