if exists('$TMUX')
  let g:fzf_prefer_tmux = 1
  let g:fzf_layout = { 'tmux': $FZF_TMUX_OPTS }
endif

" action functions
function! PRCheckoutAndReview(line) abort
  let pr_number = matchstr(a:line, '#\zs\d\+')
  if pr_number != ""
    echom "Running checkout on PR #".pr_number
    let output = systemlist("gh pr checkout ".pr_number)
    if v:shell_error 
      throw "Cannot find PR for #".pr_number
    endif
    for msg in output
      echo msg
    endfor
    let base = system("gh pr view ".pr_number." --json baseRefName | jq -r '.baseRefName'")
    if v:shell_error 
      throw "Cannot find baseRefName for #".pr_number
    endif
    let base = trim(base)
    exec "DiffHistory ".base
  endif
endfunction

function! DeleteBuffers(buffers)
  let buf_numbers = filter(map(a:buffers, {_, buf_str ->  matchstr(buf_str, '\[\zs\d\+\ze\]')}), 'v:val != ""')
  if len(buf_numbers) > 0
    exec "bwipeout ".join(buf_numbers)
  endif
endfunction
" -------------------
"
function! s:fzf_delete_buffers() abort
  call fzf#vim#buffers('', fzf#vim#with_preview({ 
        \ 'placeholder': "{1}", 
        \ 'options':['--multi','--header-lines=0', '--prompt', 'Buf Delete> '],
        \ 'sink*':  funcref("DeleteBuffers") 
        \ }))
endfunction

function! s:find_dirs()
  call fzf#run(fzf#wrap({
        \ 'source': $FZF_ALT_C_COMMAND,
        \ 'options': $FZF_ALT_C_OPTS
        \ }))
endfunction

function! s:find_prs()
  call fzf#run(fzf#wrap({
        \ 'source': $FZF_GH_PRS_LIST, 
        \ 'options': $FZF_GH_PRS_LIST_OPTIONS,
        \ 'sink':funcref('PRCheckoutAndReview') 
        \ }))
endfunction

" commands
command! -bang -nargs=* RG call fzf#vim#grep2($RG_CMD. " -- ", <q-args>, fzf#vim#with_preview(), <bang>0)

inoremap <expr> <c-x><c-f> fzf#vim#complete#path($FD_BASE_CMD . " ". $FD_IGNORE_OPTS)

nmap <silent> <leader>f :Files<CR>
nmap <silent> <leader>F :call <SID>find_dirs()<CR>
nmap <silent> <leader>r :RG<CR>
nmap <silent><expr> <leader>R ':RG '.expand('<cword>').'<CR>'
nmap <silent> <leader>b :Buffers<CR>
nmap <silent> <leader>B :call <SID>fzf_delete_buffers()<CR>
nmap <silent> <leader>gp :call <SID>find_prs()<CR>

