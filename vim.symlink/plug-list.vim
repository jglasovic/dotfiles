call plug#begin('~/.vim/plugged')
  Plug 'junegunn/fzf', {'do': {-> fzf#install()}}
  Plug 'junegunn/fzf.vim'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-commentary'
  Plug 'pgr0ss/vim-github-url'
  Plug 'mhinz/vim-signify'
  Plug 'christoomey/vim-tmux-navigator'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'hoob3rt/lualine.nvim'
  Plug 'petobens/poet-v'
  Plug 'puremourning/vimspector'
  Plug 'neoclide/coc.nvim', {'branch': 'release'} " upgrading to native lsp, need more time :)
"  Plug 'neovim/nvim-lspconfig
"  Plug 'williamboman/nvim-lsp-installer'
call plug#end()
