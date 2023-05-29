setlocal wrap
augroup close_dbout
  autocmd!
  autocmd BufWritePre <buffer> call utils#close_buffers_by_name_contains(['dbout'])
augroup end

if has('nvim')
  let has_cmp = luaeval("pcall(require, 'cmp')")
  if has_cmp
    call luaeval("require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })")
  endif
endif
