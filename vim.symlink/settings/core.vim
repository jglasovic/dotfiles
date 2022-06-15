syntax on
filetype plugin indent on
set confirm
set encoding=utf-8
set autoindent
set nowrap
set expandtab
set tabstop=2
set shiftwidth=2
set backspace=2
" set cursorline
set guicursor=
set cursorlineopt=number
set hidden
set switchbuf=usetab,newtab
set wildmode=longest:full,full
set wildmenu
set wildignore=*.o,*~
set wildignorecase
set nobackup
set nowritebackup
set cmdheight=2
set shortmess+=c
set updatetime=100
set spelllang=en_us
set noshowmode
set clipboard=unnamedplus
set noswapfile
set ignorecase
set smartcase
set smartindent
set scrolloff=12


" Line numbers
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
  set list
  set signcolumn=yes:1

  " Permanent undo - nvim undofiles are incompatible with vim undofiles
  set undodir=~/.vim/vimdid
  set undofile

  " Nvim python support for virtual envs: https://github.com/deoplete-plugins/deoplete-jedi/wiki/Setting-up-Python-for-Neovim
  let g:python_host_prog = '~/.pyenv/versions/neovim2/bin/python'
  let g:python3_host_prog = '~/.pyenv/versions/neovim3/bin/python'
else
  set re=0 "fix vi highlighting
endif

