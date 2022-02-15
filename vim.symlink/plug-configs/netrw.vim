let g:netrw_liststyle = 3
let g:netrw_winsize = 25
let g:netrw_banner = 0
let g:netrw_localcopydircmd = 'cp -r'
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'


hi! link netrwMarkFile Search

"open directory of the current file
nnoremap <leader>t :Lexplore %:p:h<CR>
"open current working directory
nnoremap <Leader>T :Lexplore<CR>


function! s:OpenFileAndCloseNetrwOrExtendDir()
	exec "normal \<plug>NetrwLocalBrowseCheck"
	if getline(".") !~ "/"
		Lexplore
	endif
endfunction


function! NetrwRemoveRecursive()
  if &filetype ==# 'netrw'
    cnoremap <buffer> <CR> rm -r<CR>
    normal mu
    normal mf

    try
      normal mx
    catch
      echo "Canceled"
    endtry

    cunmap <buffer> <CR>
  endif
endfunction

function! NetrwMapping()
	"if vim opened in directory, use current
	if len(getbufinfo({'buflisted':1})) == 1
		let g:netrw_browse_split = 0
		nmap <buffer> <CR> <plug>NetrwLocalBrowseCheck
	else
		let g:netrw_browse_split = 4
		nmap <buffer> <CR> :call <SID>OpenFileAndCloseNetrwOrExtendDir()<CR>
	endif


	"refresh
	nmap <leader>R <plug>NetrwRefresh
	"go back in history
	nmap <buffer> H u
	"go up in directory
	nmap <buffer> h -^
	"open a directory or a file
	nmap <buffer> l <plug>NetrwLocalBrowseCheck
	"toggle the dotfiles
	nmap <buffer> . gh
	"close the preview window
	nmap <buffer> P <C-w>z
	"close
	nmap <buffer> <leader>t :Lexplore<CR>

	"toggles the mark on a file or directory
	nmap <buffer> <TAB> mf
	"unmark all the files in the current buffer
	nmap <buffer> <S-TAB> mF
	"remove all the marks on all files
	nmap <buffer> <leader><TAB> mu

	"create a file
	nmap <buffer> ff %:w<CR>:buffer #<CR>
	"rename a file
	nmap <buffer> fe R
	"copy the marked files
	nmap <buffer> fc mc
	"mark and copy in one
	nmap <buffer> fC mtmc
	"move marked files
	nmap <buffer> fx mm
	"mark and move in one
	nmap <buffer> fX mtmm
	"run external commands on the marked files
	nmap <buffer> f; mx

	"show a list of marked files
	nmap <buffer> fl :echo join(netrw#Expose("netrwmarkfilelist"), "\n")<CR>
	"Show the target directory
	nmap <buffer> fq :echo 'Target:' . netrw#Expose("netrwmftgt")<CR>

	"create a bookmark
	nmap <buffer> bb mb
	"remove the most recent bookmark
	nmap <buffer> bd mB
	"jump to the most recent bookmark
	nmap <buffer> bl gb
	
	"remove
	nmap <buffer> FF :call NetrwRemoveRecursive()<CR>
endfunction

augroup netrw_mapping
  autocmd!
  autocmd filetype netrw call NetrwMapping()
augroup END
