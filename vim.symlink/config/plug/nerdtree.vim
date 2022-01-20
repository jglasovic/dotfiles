"show hidden files
let NERDTreeShowHidden=1
"change working dir when changing root
let NERDTreeChDirMode=2
" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
" Close the tab if NERDTree is the only window remaining in it.
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

function s:ToggleNerdTreeFind()
  if exists("g:NERDTree")
    if g:NERDTree.IsOpen()
      NERDTreeToggle
    else
      NERDTreeFind
    endif
  endif
endfunction


function! NERDTreeCustomOpenDir(node)
  call a:node.activate()
endfunction

function! NERDTreeCustomOpenNode(node)
  call a:node.open({'where': 't', 'reuse': 'all', 'keepopen': 0, 'stay': 0})
endfunction

let dirKeyMap = {
    \ 'key': '<ENTER>',
    \ 'scope': 'DirNode',
    \ 'callback': 'NERDTreeCustomOpenDir',
    \ 'quickhelpText': 'open dir',
    \ 'override': 1
    \ }

let nodeKeyMap = {
    \ 'key': '<ENTER>',
    \ 'scope': 'FileNode',
    \ 'callback': 'NERDTreeCustomOpenNode',
    \ 'quickhelpText': 'open node',
    \ 'override': 1
    \ }

autocmd VimEnter * call NERDTreeAddKeyMap(dirKeyMap) | call NERDTreeAddKeyMap(nodeKeyMap)

let NERDTreeMapOpenInTab='<ENTER>'
let NERDTreeQuitOnOpen=1

nmap <silent> <leader>] :call <SID>ToggleNerdTreeFind()<CR>
