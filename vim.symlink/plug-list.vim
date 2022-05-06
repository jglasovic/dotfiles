call plug#begin('~/.vim/plugged')
  Plug 'christoomey/vim-tmux-navigator'
  Plug 'junegunn/fzf', {'do': {-> fzf#install()}}
  Plug 'junegunn/fzf.vim'

  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-commentary'

  Plug 'pgr0ss/vim-github-url'
  Plug 'joshdick/onedark.vim'

  if has('nvim')
    Plug 'nvim-lua/plenary.nvim'
    Plug 'lewis6991/gitsigns.nvim'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'petobens/poet-v'
    Plug 'puremourning/vimspector'
    Plug 'jose-elias-alvarez/null-ls.nvim'
    Plug 'neovim/nvim-lspconfig'
    Plug 'williamboman/nvim-lsp-installer'
  else
    Plug 'neoclide/coc.nvim', {'branch': 'release'} " use coc vith vi
  endif
call plug#end()
