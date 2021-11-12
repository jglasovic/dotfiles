""NerdTree
nnoremap <leader>] :NERDTreeToggle<CR>
""Reload Vim configuration
nnoremap <leader>. :source $MYVIMRC<CR>
""Toggle 'set list' (toggles invisible characters)
nnoremap <leader>l :set list!<CR>
"Toggle line numbers
nnoremap <leader>n :call ToggleLineNumbers()<CR>
"Close
nnoremap <leader>q :close<CR>
""Exit insert mode
inoremap ;; <Esc>
"Mapping for saving
nnoremap <C-s> :w<CR>

""Mappings for opening new splits
""Window
nnoremap <leader>sw<left>  :topleft  vnew<CR>
nnoremap <leader>sw<right> :botright vnew<CR>
nnoremap <leader>sw<up>    :topleft  new<CR>
nnoremap <leader>sw<down>  :botright new<CR>

""Buffer
nnoremap <leader>sb<left>   :leftabove  vnew<CR>
nnoremap <leader>sb<right>  :rightbelow vnew<CR>
nnoremap <leader>sb<up>     :leftabove  new<CR>			
nnoremap <leader>sb<down>   :rightbelow new<CR>

""Terminal
nnoremap <leader>st<left>   :leftabove  vnew \| :term <CR>
nnoremap <leader>st<right>  :rightbelow vnew \| :term<CR>
nnoremap <leader>st<up>     :leftabove   new \| :term<CR>
nnoremap <leader>st<down>   :rightbelow  new \| :term<CR>

""Manipulating window focus
nnoremap <leader><left>  <c-w>h<CR>
nnoremap <leader><down>  <c-w>j<CR>
nnoremap <leader><up>    <c-w>k<CR>
nnoremap <leader><right> <c-w>l<CR>

""Resize view
nnoremap <leader>v<left> :vertical resize -10<CR>
nnoremap <leader>v<right> :vertical resize +10<CR>
nnoremap <leader>v<up> :resize +10<CR>
nnoremap <leader>v<down> :resize -10<CR>

""Jumps all mode
nnoremap <S-left> 0
nnoremap <S-right> $
nnoremap <S-up> gg
nnoremap <S-down> G

inoremap <S-left> <C-o>0
inoremap <S-right> <C-o>$
inoremap <S-up> <C-o>gg
inoremap <S-down> <C-o>0

vnoremap <S-left> 0
vnoremap <S-right> $
vnoremap <S-up> gg
vnoremap <S-down> G

"tnoremap <S-right> 0
"tnoremap <S-left> $
"tnoremap <C>
"
""Mappings for switching
nnoremap <C-i> :tabnext<CR>
"Terminal exit insert mode
tnoremap <Esc> <C-\><C-n>
tnoremap <S> <D>
""Mapping to select the last-changed text
"noremap gV `[v`]
"
""Mapping to toggle search hilighting
""Found at <http://vim.wikia.com/wiki/Highlight_all_search_pattern_matches>
"noremap <leader>h :set hlsearch! hlsearch?<CR>
"
""Mapping that uses sudo to save a non-writable file when accidentally forgetting to start vim as root
"cnoremap w!! %!sudo tee > /dev/null %
"
""Mappings for interacting with the system clipboard
""Found at <http://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/>
"xnoremap <leader>y "+y
"xnoremap <leader>d "+d
"nnoremap <leader>p "+p
"nnoremap <leader>P "+P
"xnoremap <leader>p "+p
"xnoremap <leader>P "+P
"
""Mapping for Dash search
"nmap <silent> <leader>d <Plug>DashSearch
"
""Mapping to convert mixed line endings to LF-only (Unix)
"nnoremap <leader>% :call ForceLF()<CR>
"

""Mapping to toggle undotree
"nnoremap <leader>u :UndotreeToggle<CR>
"
""Mapping to toggle auto-indenting for code paste
""Don't bother with pastetoggle, since it doesn't cooperate with vim-airline: <https://github.com/bling/vim-airline/issues/219>
"nnoremap <leader>v :set invpaste<CR>
"
""Mapping that deletes a buffer without closing its window
""Found at <https://stackoverflow.com/questions/1444322/how-can-i-close-a-buffer-without-closing-the-window#comment16482171_5179609>
"nnoremap <silent> <leader>x :ene<CR>:bd #<CR>
"
""Mapping to strip trailing whitespace
"nnoremap <silent> <leader>$ :call Preserve("%s/\\s\\+$//e")<CR>
"
""Mapping to auto-indent entire file
"nnoremap <silent> <leader>= :call Preserve('normal gg=G')<CR>
"
""Mapping to sort words inside a single line
""Found at <http://stackoverflow.com/a/1329899/278810>
"xnoremap <leader>, d:execute 'normal a' . join(sort(split(getreg('"'))), ' ')<CR>
"
"
""Mapping for adding JavaScript console logs
"nnoremap <leader>jl a console.log('');<ESC>hhi
"
""Shows the syntax highlighting group used at the cursor.
""Found at <http://vim.wikia.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor>
"map <F10> :echo "hi<". synIDattr(synID(line('.'),col('.'),1),"name") . '> trans<'
"  \ . synIDattr(synID(line('.'),col('.'),0),"name") . "> lo<"
"  \ . synIDattr(synIDtrans(synID(line('.'),col('.'),1)),"name") . ">"<CR>w
"

