function! s:vcr_querry()
  let rest_exec_buffer_name = expand('%')
  let b:vrc_output_buffer_name = substitute(rest_exec_buffer_name, ".rest", ".http", "")
  call VrcQuery()
endfunction

nnoremap <buffer>gd :call <SID>vcr_querry()<CR>
