let mapleader=" "

""Mappings for opening new splits
" Window
nmap <leader>wh   :topleft  vnew<CR>
nmap <leader>wl   :botright vnew<CR>
nmap <leader>wk   :topleft  new<CR>
nmap <leader>wj   :botright new<CR>

" Buffer
nmap <leader>wbh  :leftabove  vnew<CR>
nmap <leader>wbl  :rightbelow vnew<CR>
nmap <leader>wbk  :leftabove  new<CR>
nmap <leader>wbj  :rightbelow new<CR>

" Insert mode exit
inoremap ;; <Esc>
" Terminal exit
tnoremap ;; <C-\><C-n>

" Reload Vim configuration
nmap <leader>. :source $MYVIMRC<CR>

" Toggle 'set list' (toggles invisible characters)
nmap <leader>i :set list!<CR>

" Toggle line numbers
nnoremap <leader>n :call ToggleLineNumbers()<CR>

" Close buffer
nnoremap <C-w> :bd<CR>

" Exit vim
nnoremap <C-q> :q<CR>

" Mapping for saving
noremap  <C-s>      :w<CR>
noremap! <C-s> <Esc>:w<CR>

" Spell check
nmap <leader>S :call ToggleSpellchecking()<CR>

" Find
nmap <silent> <leader>p :Files<CR>
nmap <silent> <leader>P :Rg<CR>
nmap <silent> <leader>s :Buffers<CR>

" Search hi
nnoremap <silent><expr> <leader>f (&hls && v:hlsearch ? ':nohls' : ':set hls')."\n"

" Jump to start and end of line using the home row keys
map H ^
map L $

" change buffers
nnoremap <leader>l :bn<CR>
nnoremap <leader>h :bp<CR>

" Toggles between buffers
nnoremap <leader><leader> <c-^>

" No arrow keys
map <up>    :echo "No!"<CR>
map <down>  :echo "No!"<CR>
map <left>  :echo "No!"<CR>
map <right> :echo "No!"<CR>

"paste
xnoremap <silent> p p:let @+=@0<CR>:let @"=@0<CR>

" Resize view
nnoremap <C-right>  :vertical resize +10<CR>
nnoremap <C-left>   :vertical resize -10<CR>
nnoremap <C-up>     :resize +10<CR>
nnoremap <C-down>   :resize -10<CR>

" content move
"<A-k> == ˚
"<A-j> == ∆
nnoremap ∆        :m .+1<CR>==
nnoremap ˚        :m .-2<CR>==
inoremap ∆ <Esc>  :m .+1<CR>==gi
inoremap ˚ <Esc>  :m .-2<CR>==gi
vnoremap ∆        :m '>+1<CR>gv=gv
vnoremap ˚        :m '<-2<CR>gv=gv
