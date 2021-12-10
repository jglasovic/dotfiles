""Mappings for opening new splits
""Window
nmap <leader>sw<left>  :topleft  vnew<CR>
nmap <leader>sw<right> :botright vnew<CR>
nmap <leader>sw<up>    :topleft  new<CR>
nmap <leader>sw<down>  :botright new<CR>

""Buffer
nmap <leader>sb<left>   :leftabove  vnew<CR>
nmap <leader>sb<right>  :rightbelow vnew<CR>
nmap <leader>sb<up>     :leftabove  new<CR>
nmap <leader>sb<down>   :rightbelow new<CR>

"Terminal //not tmux
nmap <leader>st<left>   :leftabove  vnew \| :term <CR>
nmap <leader>st<right>  :rightbelow vnew \| :term<CR>
nmap <leader>st<up>     :leftabove   new \| :term<CR>
nmap <leader>st<down>   :rightbelow  new \| :term<CR>

""Manipulating window focus
noremap <C-left>  <C-w>h<CR>
noremap <C-down>  <C-w>j<CR>
noremap <C-up>    <C-w>k<CR>
noremap <C-right> <C-w>l<CR>

""Resize view
nmap <leader>v<left> :vertical resize -10<CR>
nmap <leader>v<right> :vertical resize +10<CR>
nmap <leader>v<up> :resize +10<CR>
nmap <leader>v<down> :resize -10<CR>

""Cursor jumps
nnoremap <S-left> 0
nnoremap <S-right> $
nnoremap <S-up> gg
nnoremap <S-down> G

inoremap <S-left> <C-o>0
inoremap <S-right> <C-o>$
inoremap <S-up> <C-o>gg
inoremap <S-down> <C-o>G

vnoremap <S-left> 0
vnoremap <S-right> $
vnoremap <S-up> gg
vnoremap <S-down> G

""Mappings for tabs
nnoremap <leader><right> :tabprev<CR>
nnoremap <leader><left> :tabnext<CR>

"System clipboard
xnoremap <leader>y "+y
xnoremap <leader>d "+d
nnoremap <leader>p "+p
nnoremap <leader>P "+P
xnoremap <leader>p "+p
xnoremap <leader>P "+P


"Terminal exit insert mode
tnoremap <Esc> <C-\><C-n>
"NerdTree
nmap <leader>] :NERDTreeToggle<CR>
""Reload Vim configuration
nmap <leader>. :source $MYVIMRC<CR>
""Toggle 'set list' (toggles invisible characters)
nmap <leader>l :set list!<CR>
"Toggle line numbers
nnoremap <leader>n :call ToggleLineNumbers()<CR>
"Close
nnoremap<leader>q :close<CR>
""Exit insert mode
inoremap ;; <Esc>
"Mapping for saving
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>
"Redo
nmap r <C-r>

