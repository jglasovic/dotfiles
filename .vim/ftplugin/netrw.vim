setlocal bufhidden=wipe
setlocal nopreviewwindow

function! s:get_marked_or_current()
  let marked_paths = netrw#Expose("netrwmarkfilelist")
  if type(marked_paths) == v:t_list && len(marked_paths) > 0
    return marked_paths
  endif
  let path = glob(b:netrw_curdir . '/' . expand('<cfile>'))
  return [path]
endfunction

" delete has some issues in netrw, using custom function
" if marked files, ask to delete them, else ask to delete file under cursor
function! s:delete_recursive()
  let paths = s:get_marked_or_current()
  let msg_paths = join(paths, "\n")
  echohl ErrorMsg 
  echo msg_paths
  echohl None
  let l:choice = confirm("Delete with `rm -r`?", "&yes\n&no", 0)

  if l:choice == 0 || l:choice == 2
    echo "Canceled!"
  elseif l:choice == 1
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
nmap <buffer> <silent><Esc> :pclose \| bd<CR>
"refresh
nmap <buffer> <leader>r <plug>NetrwRefresh
"go back in history
nmap <buffer> H u
"go up in directory
nmap <buffer> h -^
"open a directory or a file (close preview if exists)
nmap <buffer> <silent><CR> :pclose <CR><plug>NetrwLocalBrowseCheck
nmap <buffer> <silent>l <CR>
"toggle the dotfiles
nmap <buffer> . gh
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
"delete marked or file/dir under the cursor (override default D)
nmap <buffer> D :call <SID>delete_recursive()<CR>

"show a list of marked files
nmap <buffer> fl :echo join(netrw#Expose("netrwmarkfilelist"), "\n")<CR>
"Show the target directory
nmap <buffer> ft :echo 'Target:' . netrw#Expose("netrwmftgt")<CR>

"create a bookmark
nmap <buffer> bb mb
"delete the most recent bookmark
nmap <buffer> bd mB
"jump to the most recent bookmark
nmap <buffer> bj gb

" fix tmux navigate left
nmap <buffer> <silent> <C-l> :<C-U>TmuxNavigateRight<CR>
