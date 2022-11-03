let g:netrw_dirhistmax = 0
let g:netrw_liststyle = 0
let g:netrw_localcopycmdopt='-R'
let g:netrw_localmovecmd='mv'
let g:netrw_localmovecmdopt="-r"
hi! link netrwMarkFile Search
"open directory of the current file
nnoremap <leader>e :Explore <CR>
"open current working directory
nnoremap <Leader>E :Explore $PWD<CR>
