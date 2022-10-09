augroup close_dbout
  autocmd!
  autocmd BufWritePre <buffer> call CloseBuffers(['dbout'])
augroup end
