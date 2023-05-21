let mapleader=" "
" No arrow keys
map <up>    :echo "No!"<CR>
map <down>  :echo "No!"<CR>
map <left>  :echo "No!"<CR>
map <right> :echo "No!"<CR>
" Reload vim
nnoremap <leader>v :source $MYVIMRC<CR>
""Mappings for opening new splits
nmap <leader>wh   :topleft  vnew<CR>
nmap <leader>wl   :botright vnew<CR>
nmap <leader>wk   :topleft  new<CR>
nmap <leader>wj   :botright new<CR>
" Toggle 'set list' (toggles invisible characters)
nmap <leader>ic :set list!<CR>
" Toggle line numbers
nnoremap <leader>ln :call utils#toggle_line_numbers()<CR>
" Close buffer
nnoremap <C-w> :bd<CR>
" Exit vim
nnoremap <C-q> :q<CR>
" Write
noremap  <C-s>      :w<CR>
noremap! <C-s> <Esc>:w<CR>
" Search hi toggle
nnoremap <silent><expr> <leader>h (&hls && v:hlsearch ? ':nohls' : ':set hls')."\n"
" Jump to start and end of line using the home row keys
map H ^
map L $
" Toggles between buffers
nnoremap <leader><leader> <c-^>
" Shortcuts for substitutions
nnoremap <leader>sg :%s///g<left><left><left>
nnoremap <leader>sl :s///g<left><left><left>
" Paste and hold position
xnoremap <silent> p p:let @+=@0<CR>:let @"=@0<CR>
" Quick access for playback q register recording
" qq - start recording, q - stop recording, Q - playback
noremap Q @q
" Resize view
nnoremap <M-right>  :vertical resize +10<CR>
nnoremap <M-left>   :vertical resize -10<CR>
nnoremap <M-up>     :resize +10<CR>
nnoremap <M-down>   :resize -10<CR>
" Content move
nnoremap <M-j>      :m .+1<CR>==
nnoremap <M-k>      :m .-2<CR>==
inoremap <M-j> <Esc>:m .+1<CR>==gi
inoremap <M-k> <Esc>:m .-2<CR>==gi
vnoremap <M-j>      :m '>+1<CR>gv=gv
vnoremap <M-k>      :m '<-2<CR>gv=gv
