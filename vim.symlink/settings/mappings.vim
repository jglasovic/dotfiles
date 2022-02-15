"Mapping <space> to <leader> for Normal, Visual, Select and Operator-pending modes
map <space> <leader>

""Mappings for opening new splits
" Window
nmap <leader>wh :topleft  vnew<CR>
nmap <leader>wl :botright vnew<CR>
nmap <leader>wk :topleft  new<CR>
nmap <leader>wj :botright new<CR>

" Buffer
nmap <leader>wbh :leftabove  vnew<CR>
nmap <leader>wbl :rightbelow vnew<CR>
nmap <leader>wbk :leftabove  new<CR>
nmap <leader>wbj :rightbelow new<CR>

" Exit
inoremap ;; <Esc>

" Terminal exit insert mode
tnoremap ;; <C-\><C-n>

" Reload Vim configuration
nmap <leader>. :source $MYVIMRC<CR>

" Toggle 'set list' (toggles invisible characters)
nmap <leader>i :set list!<CR>

" Toggle line numbers
nnoremap <leader>n :call ToggleLineNumbers()<CR>

" Close
nnoremap <leader>q :close<CR>

" Mapping for saving
noremap <C-s> :w<CR>
noremap! <C-s> <Esc>:w<CR>

" Spell check
nmap <leader>S :call ToggleSpellchecking()<CR>

" Find
nmap <silent> <leader>p :Files<CR>
nmap <silent> <leader>P :Rg<CR>
nmap <silent> <leader>s :Buffers<CR>

" Search hi
nnoremap <silent><expr> <Leader>f (&hls && v:hlsearch ? ':nohls' : ':set hls')."\n"

" Jump to start and end of line using the home row keys
map H ^
map L $

" No arrow keys
nnoremap <up> :echo "No!"<CR>
nnoremap <down> :echo "No!"<CR>

" Toggles between buffers
nnoremap <space><space> <c-^>

" Left and right for buffers
nnoremap <left> :bp<CR>
nnoremap <right> :bn<CR>

" Resize view
nnoremap <C-left> :vertical resize -10<CR>
nnoremap <C-right> :vertical resize +10<CR>
nnoremap <C-up> :resize +10<CR>
nnoremap <C-down> :resize -10<CR>
