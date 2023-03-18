function! s:ripgrep_fzf(query)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --hidden --smart-case --glob "!{$FZF_EXCLUDE}" -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), 0)
endfunction

function! s:find_dirs()
  let command_fmt = 'rg --hidden --smart-case --files --glob "!{$FZF_EXCLUDE}" --null 2> /dev/null | xargs -0 dirname | sort -u'
  call fzf#run(fzf#wrap({'source': command_fmt}))
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
command! -nargs=? RG call s:ripgrep_fzf(<q-args>)

" Find
nmap <silent> <leader>f :Files<CR>
nmap <silent> <leader>F :RG<CR>
nmap <silent> <leader>b :Buffers<CR>
nmap <silent> <leader>B :BDelete<CR>
nmap <silent> <leader>df :Dirs<CR>
nmap <silent> <leader>gf :GFiles<CR>

