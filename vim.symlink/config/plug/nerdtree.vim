" automatic NERDTree mirroring on tab switching
" when having just one window in the tab
function MirrorNerdTreeIfOneWindow()
  if winnr("$") < 2
    NERDTreeMirror
    " hack to move the focus from the NERDTree to the main window
    wincmd p
    wincmd l
  endif
endfunction

"autocmd VimEnter * silent NERDTree
"autocmd BufEnter * silent exe MirrorNerdTreeIfOneWindow()
autocmd TabEnter * silent exe MirrorNerdTreeIfOneWindow() 
" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
" Close the tab if NERDTree is the only window remaining in it.
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

