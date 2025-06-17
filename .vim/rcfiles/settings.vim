syntax on
filetype plugin indent on

set clipboard^=unnamed,unnamedplus
set hidden
set confirm
set updatetime=100
set nobackup
set nowritebackup
set noswapfile
set laststatus=2
set incsearch
set encoding=utf-8
set mouse=a

" autoread
set autoread
augroup _checktime
  autocmd!
  autocmd FocusGained,BufEnter * silent! checktime
augroup END

" searching
set ignorecase
set smartcase
" set infercase

" folding
set foldenable
set foldmethod=indent
set foldlevel=999

" splits
set splitright

" whitespace
set tabstop=2
set shiftwidth=2
set expandtab
set backspace=2
set smarttab
set softtabstop=0

" wrapping / line height / screen
set linebreak
set wrap
set textwidth=120
set scrolloff=12

" indent
set autoindent
set smartindent

" cmd
set showcmd
set cmdheight=2
set shortmess+=c

" completion
set wildmode=longest:full,full
set wildmenu
set wildignore=*.o,*~
set wildignorecase
set completeopt=menu,menuone,noinsert,noselect

" gutters
set number relativenumber
augroup _relnum_focus
  autocmd!
  autocmd! FocusLost,InsertEnter * if &number | setl norelativenumber | else | echo "Line numbers hidden" | endif
  autocmd! FocusGained,InsertLeave * if &number | setl relativenumber | else | echo "Line numbers hidden" | endif
augroup END

if has('nvim')
  set signcolumn=yes:1
  " Permanent undo - nvim undofiles are incompatible with vim undofiles
  set undodir=$HOME/.vim/vimdid
  set undofile
else
  set re=0 "fix vi highlighting
  set ttyfast
endif

" rg
if executable('rg')
  set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

" create interstitial directories when saving files
augroup _create_dir_on_save
    autocmd!
    autocmd BufWritePre * if expand("<afile>")!~#'^\w\+:/' && !isdirectory(expand("%:h")) | execute "silent! !mkdir -p ".shellescape(expand('%:h'), 1) | redraw! | endif
augroup END

" sync system clipboard outside vim
" to " and 0 registers like yank does,
" not to lose them after d,x,c,s operations
function! s:sync_plus_and_zero_reg()
  let reg_def = getreg('0')
  let reg_plus = getreg('+')
  if reg_def!=#reg_plus
    call setreg('0', reg_plus)
    call setreg('"', reg_plus)
  endif
endfunction

augroup _sync_reg
    autocmd!
    autocmd FocusGained * call s:sync_plus_and_zero_reg()
augroup END

