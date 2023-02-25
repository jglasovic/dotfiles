let test#neovim#term_position = "vert"
let g:project_root_mappings = {}

if exists('$TMUX')
  let test#strategy = "vimux"
  let g:VimuxOrientation = "h"
  let g:VimuxHeight = "50"
endif

function! s:unset_root_path()
  if get(g:,'test#project_root', 'no') != 'no'
    unlet g:test#project_root
  endif
endfunction

function! s:get_workspace_folders(file_dir)
  let workspace_folders = [] 
  for path in get(g:, 'WorkspaceFolders', [getcwd()])
    let full_path = expand(path) 
    if stridx(a:file_dir, full_path)
      call add(workspace_folders, full_path)
    endif
  endfor
  echom workspace_folders
  return workspace_folders
endfunction

function! s:cache_project_root(file_dir, project_root_path)
  let g:project_root_mappings[a:file_dir] = a:project_root_path
endfunction

function! s:get_coc_root_patterns()
  if !exists("*coc#util#root_patterns")
    return []
  endif
  let coc_root_patterns = coc#util#root_patterns()
  return get(coc_root_patterns, 'server', []) + get(coc_root_patterns, 'buffer', []) + get(coc_root_patterns, 'global', [])
endfunction

function! s:get_project_root_by_coc_patterns(path, workspace_folders, patterns, stop)
  if len(a:patterns) == 0 || a:path == a:stop
    return a:workspace_folders[0]
  endif
  let idx = index(a:workspace_folders, a:path)
  if idx != -1
    return a:workspace_folders[idx]
  endif

  for pattern in a:patterns
    let test_path = a:path . '/' . pattern
    if !empty(glob(test_path))
      return a:path
    endif
  endfor

  return s:get_project_root_by_coc_patterns(substitute(a:path,'/[^\/]\+\(?\=\/$\|$\)', '', 'g'), a:workspace_folders, a:patterns, a:stop)
endfunction

function s:get_project_root_for_test_file()
  let test_file_dir = expand('%:p:h')
  " if cached, return root path
  if has_key(g:project_root_mappings, test_file_dir)
    return get(g:project_root_mappings, test_file_dir)
  endif

  let workspace_folders = s:get_workspace_folders(test_file_dir)
  let root_patterns = s:get_coc_root_patterns()
  return s:get_project_root_by_coc_patterns(test_file_dir, workspace_folders, root_patterns, expand('$HOME'))
endfunction

" when working with monorepo, workspace or file opened explicitly with vim, 
" wrapper function dynamicly sets project root dir based on coc#util#root_patterns
function RunTestWrapper(cmd)
  if a:cmd != 'TestLast'
    if !test#exists()
      echom "Not a test file!"
      return
    endif

    call s:unset_root_path()
    let g:test#project_root = s:get_project_root_for_test_file()
  endif
  echom g:test#project_root

  if exists('$TMUX')
    call VimuxRunCommand('cd '. g:test#project_root)
    exec a:cmd
    call VimuxRunCommand('cd -')
    return 
  endif
  exec a:cmd
endfunction

nmap <silent> <leader>tt :call RunTestWrapper('TestNearest')<CR>
nmap <silent> <leader>tT :call RunTestWrapper('TestFile')<CR>
nmap <silent> <leader>ta :call RunTestWrapper('TestSuite')<CR>
nmap <silent> <leader>t_ :call RunTestWrapper('TestLast')<CR>
