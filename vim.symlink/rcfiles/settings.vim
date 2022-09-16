syntax on
filetype plugin indent on

set clipboard^=unnamed,unnamedplus
set hidden
set confirm
set updatetime=100
set nobackup
set nowritebackup
set noshowmode
set noswapfile
set laststatus=2
set incsearch
set encoding=utf-8
set mouse=a

" autoread
set autoread
autocmd FocusGained,BufEnter * checktime

" searching
set ignorecase
set smartcase
set hlsearch

" completion
set completeopt=menu,menuone,preview

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

" cursor / rows
set cursorline
set cursorlineopt=number

" cmd
set showcmd
set cmdheight=2
set shortmess+=c

" completion
set wildmode=longest:full,full
set wildmenu
set wildignore=*.o,*~
set wildignorecase

" gutters
set number relativenumber
augroup relnum_focus
  autocmd! FocusLost,InsertEnter * if &number | setl norelativenumber | else | echom "Line numbers hidden" | endif
  autocmd! FocusGained,InsertLeave * if &number | setl relativenumber | else | echom "Line numbers hidden" | endif
augroup END

if executable('rg')
  set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif


if has('nvim')
  set signcolumn=yes:1

  " Permanent undo - nvim undofiles are incompatible with vim undofiles
  set undodir=~/.vim/vimdid
  set undofile
  " Nvim python support for virtual envs: https://github.com/deoplete-plugins/deoplete-jedi/wiki/Setting-up-Python-for-Neovim
  let g:python_host_prog = '~/.pyenv/versions/neovim2/bin/python'
  let g:python3_host_prog = '~/.pyenv/versions/neovim3/bin/python'
else
  set re=0 "fix vi highlighting
  set ttyfast
endif

" create interstitial directories when saving files
augroup CreateDirsOnSave
    autocmd!
    autocmd BufWritePre * if expand("<afile>")!~#'^\w\+:/' && !isdirectory(expand("%:h")) | execute "silent! !mkdir -p ".shellescape(expand('%:h'), 1) | redraw! | endif
augroup END

" sync system clipboard outside vim
" to " and 0 registers like yank does,
" not to lose them after d,x,c,s operations
function! SyncPlusAndZeroReg()
  let reg_def = getreg('0')
  let reg_plus = getreg('+')
  if reg_def!=#reg_plus
    call setreg('0', reg_plus)
    call setreg('"', reg_plus)
  endif
endfunction
augroup SyncRegisters
    autocmd!
    autocmd FocusGained * call SyncPlusAndZeroReg()
augroup END

