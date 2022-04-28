call plug#begin('~/.vim/plugged')
  Plug 'christoomey/vim-tmux-navigator'
  Plug 'junegunn/fzf', {'do': {-> fzf#install()}}
  Plug 'junegunn/fzf.vim'

  if has('nvim')
    Plug 'nvim-lua/plenary.nvim'
    Plug 'lewis6991/gitsigns.nvim'
    Plug 'petobens/poet-v'
    Plug 'puremourning/vimspector'
  endif

  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-commentary'

  Plug 'pgr0ss/vim-github-url'
  Plug 'neoclide/coc.nvim', {'branch': 'release'} " upgrading to native lsp, need more time :)
"  Plug 'neovim/nvim-lspconfig
"  Plug 'williamboman/nvim-lsp-installer'
  Plug 'joshdick/onedark.vim'
call plug#end()
