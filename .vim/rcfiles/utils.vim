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

function! utils#close_buffers_by_variables(dict)
  let buffers = getbufinfo()
  let num_closed = 0
  for buffer in buffers
    let bufnr = get(buffer,'bufnr',0)
    if bufnr <= 0
      continue
    endif
    let variables = get(buffer, 'variables', {})
    for [key, value] in items(a:dict)
      let var_value = get(variables, key, '')
      if var_value != value
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

function! s:get_root_dir_by_patterns(dir, patterns, stop_dir) abort
  if a:dir == a:stop_dir
    throw "Cannot find root dir by provided patterns: ".join(patterns, ' ')
  endif

  for pattern in a:patterns
    let test_pattern_path = a:dir . '/' . pattern
    if !empty(glob(test_pattern_path))
      return [pattern, a:dir]
    endif
  endfor
  let up_dir = substitute(a:dir,'/[^\/]\+\(?\=\/$\|$\)', '', 'g')
  return s:get_root_dir_by_patterns(up_dir, a:patterns, a:stop_dir)
endfunction

function! utils#get_root_dir(...) abort
  let opts = get(a:000, 0, {})
  let dir = get(opts, 'dir', expand('%:p:h'))
  let patterns = get(opts, 'patterns', [])
  let stop_dir = get(opts, 'stop_dir', expand('$HOME'))

  let workspaces = []
  if has('nvim')
    let workspaces = luaeval('vim.lsp.buf.list_workspace_folders()')
  endif
  
  if len(patterns) == 0 && len(workspaces) == 0
    throw "Missing patterns and workspaces to search for root dir!"
  endif
  " create cache if doesn't exist
  if !exists('g:root_dir_cache')
    let g:root_dir_cache = {}
  endif

  if len(patterns) > 0
    if has_key(g:root_dir_cache, dir)
      let cache = g:root_dir_cache[dir]
      for pattern in patterns
        if has_key(cache, pattern)
          return cache[pattern]
        endif
      endfor
    endif

    let [pattern, root_dir] = s:get_root_dir_by_patterns(dir, patterns, stop_dir)

    if !has_key(g:root_dir_cache, dir)
      let g:root_dir_cache[dir] = {}
    endif
    let g:root_dir_cache[dir][pattern] = root_dir
    return root_dir
  endif

  let root_dir = ''
  for workspace in workspaces
    if len(root_dir) < len(workspace) && stridx(dir, workspace) != -1
      let root_dir = workspace
    endif
  endfor
  if root_dir == ''
    throw "Cannot find root dir in workspaces!"
  endif
  return root_dir
endfunction

function! utils#test_command_time(com, ...)
  let time = 0.0
  let numberOfTimes = a:0 ? a:1 : 5000
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

function! utils#with_cache(callback, cache_key, input)
  if !has_key(g:, 'custom_cache')
    let g:custom_cache = {}
  endif
  if !has_key(g:custom_cache, a:cache_key)
    let g:custom_cache[a:cache_key] = {} 
  endif

  let value = get(g:custom_cache[a:cache_key], a:input)

  if value
    return value
  endif

  let value = call(a:callback, [a:input])
  let g:custom_cache[a:cache_key][a:input] = value
  return value
endfunction


function! utils#open_url(value)
  let formated = shellescape(a:value)
  let output = system('open_url '.formated)
  if v:shell_error 
    echom output
  endif
endfunction

function! utils#open_url_from_cursor()
  let current_line = getline('.')
  return utils#open_url(current_line)
endfunction
