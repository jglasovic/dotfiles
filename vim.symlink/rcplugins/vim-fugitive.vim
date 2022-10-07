function! s:CloseFugitive()
  let closed_buf_len = CloseBuffers(['fugitive:', 'fugitiveblame', 'QuickFix'])
  if closed_buf_len == 0
    echom "No fugitive buffers"
  endif
endfunction


function! s:view_git_history() abort
  Git difftool --name-only ! !^@
  call s:diff_current_quickfix_entry()
  " Bind <CR> for current quickfix window to properly set up diff split layout after selecting an item
  " There's probably a better way to map this without changing the window
  copen
  nnoremap <buffer> <CR> <CR><BAR>:call <sid>diff_current_quickfix_entry()<CR>
  wincmd p
endfunction

function s:diff_current_quickfix_entry() abort
  " Cleanup windows
  for window in getwininfo()
    if window.winnr !=? winnr() && (bufname(window.bufnr) =~? 'fugitive:' || bufname(window.bufnr) =~? 'fugitiveblame')
      exe 'bdelete' window.bufnr
    endif
  endfor
  cc
  call s:add_mappings()
  let qf = getqflist({'context': 0, 'idx': 0})
  if get(qf, 'idx') && type(get(qf, 'context')) == type({}) && type(get(qf.context, 'items')) == type([])
    let diff = get(qf.context.items[qf.idx - 1], 'diff', [])
    echom string(reverse(range(len(diff))))
    for i in reverse(range(len(diff)))
      exe (i ? 'leftabove' : 'rightbelow') 'vert diffsplit' fnameescape(diff[i].filename)
      call s:add_mappings()
    endfor
  endif
endfunction

function! s:add_mappings() abort
  nnoremap <buffer>]q :cnext <BAR> :call <sid>diff_current_quickfix_entry()<CR>
  nnoremap <buffer>[q :cprevious <BAR> :call <sid>diff_current_quickfix_entry()<CR>
  " Reset quickfix height. Sometimes it messes up after selecting another item
  11copen
  wincmd p
endfunction

command! DiffHistory call s:view_git_history()

nnoremap <silent><leader>gs :G<CR>
nnoremap <silent><leader>gb :G blame<CR>
nnoremap <silent><leader>gd :Gvdiffsplit!<CR>
nnoremap <silent><leader>gc :call <SID>CloseFugitive()<CR>
nnoremap <silent><leader>gD :DiffHistory<CR>

nnoremap <silent>gh :diffget //2<CR>
nnoremap <silent>gl :diffget //3<CR>


