setlocal wrap
augroup close_dbout
  autocmd!
  autocmd BufWritePre <buffer> call CloseBuffersByNameContains(['dbout'])
augroup end
