if exists('$TMUX')
  let g:fzf_layout = { 'tmux': $FZF_TMUX_OPTS }
endif

function! s:find_dirs()
  call fzf#run(fzf#wrap({'source': $FZF_ALT_C_COMMAND, 'options': $FZF_ALT_C_OPTS}))
endfunction

function! s:delete_buffers() abort
  redir => list
  silent ls
  redir END
  call fzf#run(fzf#wrap({
  \ 'source': split(list, "\n"),
  \ 'sink*': { lines -> len(lines) > 0 && execute("bwipeout " . join(map(lines, {_, line -> split(line)[0]})))},
  \ 'options': '--multi --bind ctrl-x:select-all+accept'
\ }))
endfunction


command! -nargs=0 BDelete call s:delete_buffers()
command! -nargs=0 Dirs call s:find_dirs()
" Find
nmap <silent> <leader>f :Files<CR>
nmap <silent> <leader>F :RG<CR>
nmap <silent> <leader>b :Buffers<CR>
nmap <silent> <leader>B :BDelete<CR>
nmap <silent> <leader>df :Dirs<CR>

