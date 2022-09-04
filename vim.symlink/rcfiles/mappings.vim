let mapleader=" "

" reload vim
nnoremap <leader>v :source $MYVIMRC<CR>

""Mappings for opening new splits
nmap <leader>wh   :topleft  vnew<CR>
nmap <leader>wl   :botright vnew<CR>
nmap <leader>wk   :topleft  new<CR>
nmap <leader>wj   :botright new<CR>

" Insert mode exit
inoremap ;; <Esc>
" Terminal exit
tnoremap ;; <C-\><C-n>

" Toggle 'set list' (toggles invisible characters)
nmap <leader>li :set list!<CR>

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
nmap <silent> <leader>b :Buffers<CR>

" Search hi
nnoremap <silent><expr> <leader><esc> (&hls && v:hlsearch ? ':nohls' : ':set hls')."\n"

" Jump to start and end of line using the home row keys
map H ^
map L $

" Toggles between buffers
nnoremap <leader><leader> <c-^>

" No arrow keys
map <up>    :echo "No!"<CR>
map <down>  :echo "No!"<CR>
map <left>  :echo "No!"<CR>
map <right> :echo "No!"<CR>

" fold, unfold
nnoremap <leader>ff za
nnoremap <leader>FF zA

" Maps for folding, unfolding all
nnoremap <leader>fa zM<cr>
nnoremap <leader>Fa zR<cr>

" shortcuts for substitutions
nnoremap <leader>sg :%s///g<left><left><left>
nnoremap <leader>sl :s///g<left><left><left>

" word good/bad for spell
nnoremap <leader>wg zg
nnoremap <leader>wb z=

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
