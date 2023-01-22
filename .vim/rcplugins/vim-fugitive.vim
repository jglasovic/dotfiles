function! s:delete_all_fugitive_wins_and_buffs()
  call s:delete_fugitive_wins()
  let closed_buf_len = CloseBuffersByNameContains(['fugitive:', 'fugitiveblame'])
  if closed_buf_len == 0
    echom "No fugitive buffers"
  endif
endfunction

function! s:delete_fugitive_wins()
  for window in getwininfo()
    if window.winnr !=? winnr() && (bufname(window.bufnr) =~? 'fugitive:' || bufname(window.bufnr) =~? 'fugitiveblame')
      try
        exe 'bdelete' window.bufnr
      catch
        continue
      endtry
    endif
  endfor
endfunction

function! s:get_qf_with_diff_history()
  let qf = getqflist({'context': 0, 'idx': 0})
  if get(qf, 'idx') && type(get(qf, 'context')) == type({}) && type(get(qf.context, 'items')) == type([])
    return qf
  endif
  return {}
endfunction

function! s:close_all_fugitive_and_qf()
  let qf = s:get_qf_with_diff_history()
  if qf != {}
    silent cclose
  endif
  call s:delete_all_fugitive_wins_and_buffs()
endfunction

function! s:get_compare_str(args)
  if len(a:args) == 0
    return '! !^@'
  endif

  if len(a:args) == 1
    let branch = a:args[0]
    let current_branch = FugitiveHead()
    if current_branch == branch
      echom "Already on ".branch." branch, comparing previous commit history"
      return '! !^@'
    endif
    return branch.'...'
  endif

  if len(a:args) > 2
    echom "Cannot use more than two commits or branches to compare. Comparing first two!"
  endif

  return a:args[0].'..'.a:args[1]
endfunction

" bellow is modified script: https://github.com/tpope/vim-fugitive/issues/132#issuecomment-649516204
function! s:view_git_history(...) abort
  let diff = s:get_compare_str(a:000)
  exe "Git difftool --name-only ".diff
  call s:diff_current_quickfix_entry()
  " Bind <CR> for current quickfix window to properly set up diff split layout after selecting an item
  " There's probably a better way to map this without changing the window
  11copen
  nnoremap <buffer> <CR> <CR><BAR>:call <sid>diff_current_quickfix_entry()<CR>
  wincmd p
endfunction

function! s:diff_current_quickfix_entry() abort
  " Cleanup prev fugitive windows
  call s:delete_fugitive_wins()
  " Add mappings to the qf
  cc
  call s:add_mappings()

  let qf = s:get_qf_with_diff_history()
  if qf != {}
    let diff = get(qf.context.items[qf.idx - 1], 'diff', [])
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

command! -nargs=* DiffHistory call s:view_git_history(<f-args>)

nnoremap <silent><leader>gs :G<CR>
nnoremap <silent><leader>gb :G blame<CR>
nnoremap <silent><leader>gd :Gvdiffsplit!<CR>
nnoremap <silent><leader>gc :call <SID>close_all_fugitive_and_qf()<CR>
nnoremap <silent><leader>gD :DiffHistory<CR>

nnoremap <silent>gh :diffget //2<CR>
nnoremap <silent>gl :diffget //3<CR>

