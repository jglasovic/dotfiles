function! s:CloseFugitive()
  let closed_buf_len = CloseBuffers('fugitive')
  if closed_buf_len == 0
    echom "No fugitive buffers"
  endif
endfunction

function! OpenDiff(path)
  echom a:path
endfunction

function! GitDiffBranchesSearch(branch)
  call fzf#run(fzf#wrap({'source': 'git diff --name-only '..a:branch, 'sink': funcref('OpenDiff')}))
endfunction

command! -nargs=? Diff call GitDiffBranchesSearch(<q-args>)

nnoremap <silent><leader>gs :G<CR>
nnoremap <silent><leader>gb :G blame<CR>
nnoremap <silent><leader>gd :Gvdiffsplit!<CR>
nnoremap <silent><leader>gc :call <SID>CloseFugitive()<CR>

nnoremap <silent>gh :diffget //2<CR>
nnoremap <silent>gl :diffget //3<CR>
