if !has('nvim')
  finish
endif

nnoremap <buffer><C-w> :lua require"dap".repl.close()<CR>
