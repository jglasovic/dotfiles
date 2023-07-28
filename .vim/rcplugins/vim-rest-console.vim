let g:vrc_curl_opts = {
  \ '--connect-timeout' : 5,
  \ '-L': '',
  \ '-i': '',
  \ '-sS': '',
  \ '--max-time': 10,
  \ '--ipv4': '',
  \ '-k': '',
\}

let g:vrc_show_command = 1
let g:vim_rest_console_cached_files = expand('$HOME') . "/.local/share/vrc_history"
let g:vrc_trigger = 'gd'

if empty(glob(g:vim_rest_console_cached_files ))
  silent exec "!mkdir -p ".g:vim_rest_console_cached_files 
endif

function! VRCOpen(new_buffer)
  let path_to_exec = g:vim_rest_console_cached_files 
  if a:new_buffer == 1
    let file_name = input('Enter name: ', strftime("%d%m%y_%H%M%S"))
    if file_name == ""
      return
    endif
    if stridx(file_name, '.rest') == -1
      let file_name = file_name . '.rest'
    endif
    let path_to_exec = path_to_exec ."/". file_name
  endif
  execute "e ".fnameescape(path_to_exec)
endfunction
" toggle vrc (open dir with saved input/output files)
nnoremap <leader>o :call VRCOpen(0)<CR>
" open new rest file
nnoremap <leader>O :call VRCOpen(1)<CR>
