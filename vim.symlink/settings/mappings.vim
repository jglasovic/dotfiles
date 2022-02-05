let mapleader = ","

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

" Resize view
nmap <leader>vh :vertical resize -10<CR>
nmap <leader>vl :vertical resize +10<CR>
nmap <leader>vk :resize +10<CR>
nmap <leader>vj :resize -10<CR>

" Exit
inoremap ;; <Esc>

" Terminal exit insert mode, closing FZF buffer if exists
tnoremap ;; <C-\><C-n> :call ExitFZF()<CR>

" Reload Vim configuration
nmap <leader>. :source $MYVIMRC<CR>

" Toggle 'set list' (toggles invisible characters)
nmap <leader>l :set list!<CR>

" Toggle line numbers
nnoremap <leader>n :call ToggleLineNumbers()<CR>

" Close
nnoremap<leader>q :close<CR>

" Mapping for saving
noremap <C-s> :w<CR>
noremap! <C-s> <Esc>:w<CR>

nmap <leader>s :call ToggleSpellchecking()<CR>
nmap <space><space> :Files<CR>
nmap <space>f :Rg<CR>

" Jump to start and end of line using the home row keys
map H ^
map L $

" No arrow keys
nnoremap <up> <nop>
nnoremap <down> <nop>

" Left and right for tabs
nnoremap <left> :tabprev<CR>
nnoremap <right> :tabnext<CR>

" Toggles between buffers
nnoremap <leader><leader> <c-^>

" Remove whitespace
command! KillWhitespace :normal :%s/ *$//g<cr><c-o><cr>
