if exists('$TMUX')
  let g:fzf_prefer_tmux = 1
  let g:fzf_layout = { 'tmux': $FZF_TMUX_OPTS }
endif

function! s:find_dirs()
  call fzf#run(fzf#wrap({'source': $FZF_ALT_C_COMMAND, 'options': $FZF_ALT_C_OPTS}))
endfunction

function! DeleteBuffers(buffers)
  let buf_numbers = filter(map(a:buffers, {_, buf_str ->  matchstr(buf_str, '\[\zs\d\+\ze\]')}), 'v:val != ""')
  if len(buf_numbers) > 0
    exec "bwipeout ".join(buf_numbers)
  endif
endfunction

function! s:fzf_delete_buffers() abort
  call fzf#vim#buffers('', fzf#vim#with_preview({ 
        \ 'placeholder': "{1}", 
        \ 'options':['--multi','--header-lines=0', '--prompt', 'Buf Delete> '],
        \ 'sink*':  funcref("DeleteBuffers") 
        \ }))
endfunction

command! -bang -nargs=* RG call fzf#vim#grep2($RG_CMD. " -- ", <q-args>, fzf#vim#with_preview(), <bang>0)
nmap <silent> <leader>f :Files<CR>
nmap <silent> <leader>r :RG<CR>
nmap <silent> <leader>b :Buffers<CR>
nmap <silent> <leader>B :call <SID>fzf_delete_buffers()<CR>
nmap <silent> <leader>F :call <SID>find_dirs()<CR>
nmap <silent><expr> <leader>R ':RG '.expand('<cword>').'<CR>'
inoremap <expr> <c-x><c-f> fzf#vim#complete#path($FD_BASE_CMD . " ". $FD_IGNORE_OPTS)






