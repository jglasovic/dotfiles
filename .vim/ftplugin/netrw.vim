setlocal bufhidden=wipe
setlocal nopreviewwindow

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
