setlocal bufhidden=wipe

function! s:confirm(msg)
    echo a:msg . ' '
    let l:answer = nr2char(getchar())

    if l:answer ==? 'y'
        return 1
    elseif l:answer ==? 'n' || l:answer ==? '^['
        return 0
    else
        echo 'Please enter "y" or "n"'
        return Confirm(a:msg)
    endif
endfun

function! s:get_marked_or_current()
  let marked_paths = netrw#Expose("netrwmarkfilelist")
  if type(marked_paths) == v:t_list && len(marked_paths) > 0
    return marked_paths
  endif
  let path = glob(b:netrw_curdir . '/' . expand('<cfile>'))
  return [path]
endfunction


" if marked files, ask to delete them, else ask to delete file under cursor
function! s:delete_recursive()
  let paths = s:get_marked_or_current()
  let msg_paths = join(paths, "\n")
  let msg = join(['Delete with `rm -r` path(s):', msg_paths, '? [y/n]'], "\n")
  if s:confirm(msg)
    try
      silent! execute "!rm -r " . join(paths, " ")
      echo "Deleted!"
      normal mu
    catch
      echo "Cannot delete: " . msg_paths
    endtry
  endif
endfunction

" Mappings
"close
nmap <buffer><Esc> :bd<CR>
"refresh
nmap <leader>R <plug>NetrwRefresh
"go back in history
nmap <buffer> H u
"go up in directory
nmap <buffer> h -^
"open a directory or a file
nmap <buffer> l <CR>
"toggle the dotfiles
nmap <buffer> . gh
"close the preview window
nmap <buffer> <leader>t <C-w>
"toggles the mark on a file or directory
nmap <buffer> <TAB> mf
"unmark all the files in the current buffer
nmap <buffer> <S-TAB> mF
"remove all the marks on all files
nmap <buffer> <leader><TAB> mu
"create a file
nmap <buffer> ff %:w<CR>:buffer #<CR>
"rename a file
nmap <buffer> fr R
"copy the marked files
nmap <buffer> fc mc
"mark and copy in one
nmap <buffer> fC mtmc
"move marked files
nmap <buffer> fm mm
"mark and move in one
nmap <buffer> fM mtmm
"run external commands on the marked files
nmap <buffer> f; mx
"remove marked or file/dir under the cursor (override default D)
nmap <buffer> D :call <SID>delete_recursive()<CR>

"show a list of marked files
nmap <buffer> fl :echo join(netrw#Expose("netrwmarkfilelist"), "\n")<CR>
"Show the target directory
nmap <buffer> ft :echo 'Target:' . netrw#Expose("netrwmftgt")<CR>

"create a bookmark
nmap <buffer> bb mb
"remove the most recent bookmark
nmap <buffer> bd mB
"jump to the most recent bookmark
nmap <buffer> bj gb
