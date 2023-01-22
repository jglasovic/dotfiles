let g:vrc_curl_opts = {
  \ '--connect-timeout' : 10,
  \ '-L': '',
  \ '-i': '',
  \ '-sS': '',
  \ '--max-time': 60,
  \ '--ipv4': '',
  \ '-k': '',
\}

let g:vrc_syntax_highlight_response = 0
let g:vrc_set_default_mapping = 0

augroup set_http_ft_for_output
  autocmd!
  autocmd BufRead,BufNewFile *.http :setlocal ft=http
  autocmd BufEnter *.http :setlocal buftype=
augroup END

let g:vim_rest_console_cached_files = '$HOME/.local/share/vrc_history'

if empty(glob(g:vim_rest_console_cached_files ))
  silent exec "!mkdir -p ".g:vim_rest_console_cached_files 
endif

function! s:toggle_vrc(new_buffer)
  let path_to_exec = g:vim_rest_console_saved_files
  let new_file_name = strftime("/%d%m%y_%H%M%S.rest")
  let closed = 0

  if a:new_buffer == 1
    let path_to_exec = path_to_exec . new_file_name 
  else
    let closed = CloseBuffersByFiletype(['rest', 'http'])
  endif

  if closed == 0
    execute "e ".fnameescape(path_to_exec)
  endif
endfunction

" toggle vrc (open dir with saved input/output files)
nnoremap <leader>o :call <SID>toggle_vrc(0)<CR>
" open new rest file
nnoremap <leader>O :call <SID>toggle_vrc(1)<CR>




