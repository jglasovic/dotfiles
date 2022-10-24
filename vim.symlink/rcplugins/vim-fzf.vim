function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --hidden --smart-case --glob "!{$FZF_EXCLUDE}" -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

function! FindDirs()
  let command_fmt = 'rg --hidden --smart-case --files --glob "!{$FZF_EXCLUDE}" --null 2> /dev/null | xargs -0 dirname | sort -u'
  call fzf#run(fzf#wrap({'source': command_fmt}))
endfunction

command! -nargs=0 Dirs call FindDirs()
command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
