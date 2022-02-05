call plug#begin('~/.vim/plugged')
  Plug 'preservim/nerdtree'
  Plug 'Xuyuanp/nerdtree-git-plugin'
  Plug 'junegunn/fzf', {'do': {-> fzf#install()}}
  Plug 'junegunn/fzf.vim'
  Plug 'hoob3rt/lualine.nvim'
  Plug 'tpope/vim-fugitive'
  Plug 'pgr0ss/vim-github-url'
  Plug 'mhinz/vim-signify'
  Plug 'sheerun/vim-polyglot'
  Plug 'christoomey/vim-tmux-navigator'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'tpope/vim-commentary'
  Plug 'neoclide/coc.nvim', {'branch': 'release'} " upgrading to native lsp, need more time :)
"  Plug 'neovim/nvim-lspconfig
"  Plug 'williamboman/nvim-lsp-installer'
  Plug 'petobens/poet-v'
  Plug 'puremourning/vimspector'
call plug#end()
