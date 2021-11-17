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
nnoremap q :close<CR>
""Exit insert mode
inoremap ;; <Esc>
"Mapping for saving
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>
"Redo
nmap r <C-r>


""" Coc -  Mappings  {{{

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()
" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> K :call <SID>show_documentation()<CR>
" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)
" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
" Applying codeAction to the selected region.
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)
" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)
" Map function and class text objects
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)
" Use CTRL-r for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nnoremap <silent> <C-r> <Plug>(coc-range-select)
xnoremap <silent> <C-r> <Plug>(coc-range-select)
" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>u


"}}}
