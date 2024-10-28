let g:fzf_prefer_tmux = 1
let g:fzf_layout = { 'tmux': '80%,60%', 'window': { 'width': 0.8, 'height': 0.6 } }

let g:fzf_vim = {
  \ 'files_options': $FD_CMD_OPTS,
  \ }

" action functions
function! DeleteBuffers(buffers)
  let buf_numbers = filter(map(a:buffers, {_, buf_str ->  matchstr(buf_str, '\[\zs\d\+\ze\]')}), 'v:val != ""')
  if len(buf_numbers) > 0
    exec "bwipeout ".join(buf_numbers)
  endif
endfunction
" -------------------
function! s:fzf_delete_buffers() abort
  call fzf#vim#buffers('', fzf#vim#with_preview({ 
        \ 'placeholder': "{1}", 
        \ 'options':['--multi','--header-lines=0', '--prompt', 'Buf Delete> '],
        \ 'sink*':  funcref("DeleteBuffers") 
        \ }))
endfunction

function! RipgrepFzf(query, fullscreen)
  let command_fmt = $RG_CMD . ' -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let spec = {'options': ['--disabled', '--query', a:query, '--bind', 'change:'.$rg_change, '--bind', 'ctrl-r:'.$rg_toggle_vsc_ignore]}
  let spec = fzf#vim#with_preview(spec, 'right', 'ctrl-/')
  call fzf#vim#grep(initial_command, 1, spec, a:fullscreen)
endfunction

" commands override
command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
command! -bang -nargs=? -complete=dir Files call fzf#vim#files(<q-args>, {}, <bang>0)

" mappings
inoremap <expr> <c-x><c-f> fzf#vim#complete#path($FZF_DEFAULT_COMMAND)
nmap <silent> <leader>f :Files<CR>
nmap <silent> <leader>r :RG<CR>
nmap <silent><expr> <leader>R ':RG '.expand('<cword>').'<CR>'
nmap <silent> <leader>b :Buffers<CR>
nmap <silent> <leader>B :call <SID>fzf_delete_buffers()<CR>

