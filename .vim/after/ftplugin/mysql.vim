setlocal wrap
setlocal omnifunc=vim_dadbod_completion#omni

augroup close_dbout
  autocmd!
  autocmd BufWritePre <buffer> call utils#close_buffers_by_name_contains(['dbout'])
augroup end

