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
  let closed_buf_len = utils#close_buffers_by_name_contains(['fugitive:', 'fugitiveblame'])
  if closed_buf_len == 0
    echo "No fugitive buffers"
  endif
endfunction

function! s:reset_qf() abort
  11copen
  wincmd p
endfunction

function! s:diff_current_quickfix_entry(...) abort
  let editable = a:0 == 0 ? 0 : a:1
  cc
  if editable
    exec "Gedit"
  endif
  call s:reset_qf()
  let qf = s:get_qf_with_diff_history()
  if qf == {}
    return
  endif
  let diff = get(qf.context.items[qf.idx - 1], 'diff', [])
  for i in reverse(range(len(diff)))
    let diffcmd = (i ? 'rightbelow' : 'leftabove'). ' vert diffsplit '.fnameescape(diff[i].filename)
    exec diffcmd
    wincmd p
    call s:reset_qf()
  endfor
endfunction


function! GitDiffTool(...) abort
  call s:close_all_fugitive_and_qf()
  let compare_args = copy(a:000)
  let modifiable = 0
  if len(compare_args) == 1
    call add(compare_args, ' ')
    let modifiable = 1
  endif
  let compare_str = join(compare_args, '...')
  let cmd = 'Git difftool --name-status '.compare_str
  exec cmd
  call s:diff_current_quickfix_entry(modifiable)
  11copen
  if modifiable
    nnoremap <buffer> <CR> :call <SID>delete_fugitive_wins()<CR><BAR><CR><BAR>:call <SID>diff_current_quickfix_entry(1)<CR>
  else
    nnoremap <buffer> <CR> :call <SID>delete_fugitive_wins()<CR><BAR><CR><BAR>:call <SID>diff_current_quickfix_entry()<CR>
  endif
  wincmd p
endfunction


command! -nargs=* GitDiff call GitDiffTool(<f-args>)
command! -nargs=0 GitDiffCommit call GitDiffTool('!^', '!')

nnoremap <silent><leader>G :call <SID>close_all_fugitive_and_qf()<CR>
