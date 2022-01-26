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

""Manipulating window focus
noremap <C-left>  <C-w>h<CR>
noremap <C-down>  <C-w>j<CR>
noremap <C-up>    <C-w>k<CR>
noremap <C-right> <C-w>l<CR>

"Resize view
nmap <leader>v<left> :vertical resize -10<CR>
nmap <leader>v<right> :vertical resize +10<CR>
nmap <leader>v<up> :resize +10<CR>
nmap <leader>v<down> :resize -10<CR>

"Terminal exit insert mode, closing specific buffer if exists
tnoremap <Esc> <C-\><C-n> :call ExitFZF()<CR>
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

nmap <leader>s :call ToggleSpellchecking()<CR>

nmap <space><space> :Files<CR>
nmap <space>f :Rg<CR>

