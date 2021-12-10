call plug#begin('~/.vim/plugged')
  Plug 'preservim/nerdtree'
  Plug 'Xuyuanp/nerdtree-git-plugin'
  Plug 'junegunn/fzf', {'do': {-> fzf#install()}}
  Plug 'junegunn/fzf.vim'
  Plug 'hoob3rt/lualine.nvim'
  Plug 'tpope/vim-fugitive'
  Plug 'mhinz/vim-signify'
  Plug 'sheerun/vim-polyglot'
  Plug 'christoomey/vim-tmux-navigator'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'neoclide/coc.nvim', {'branch': 'release'} " upgrading to native lsp, need more time :)  
"  Plug 'neovim/nvim-lspconfig'
"  Plug 'williamboman/nvim-lsp-installer'
  Plug 'petobens/poet-v'

"colorscheme
  Plug 'joshdick/onedark.vim'
  Plug 'whatyouhide/vim-gotham'
  Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
call plug#end()
