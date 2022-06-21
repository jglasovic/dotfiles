call plug#begin(g:plugged_dir_path)
  Plug 'christoomey/vim-tmux-navigator'
  Plug 'junegunn/fzf', {'do': {-> fzf#install()}}
  Plug 'junegunn/fzf.vim'

  if has('nvim')
    Plug 'nvim-lua/plenary.nvim'
    Plug 'lewis6991/gitsigns.nvim'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'petobens/poet-v'
    Plug 'puremourning/vimspector'
    if $USE_LSP == 'true'
      Plug 'neovim/nvim-lspconfig'
      Plug 'hrsh7th/nvim-cmp'
      Plug 'hrsh7th/cmp-nvim-lsp'
      Plug 'saadparwaiz1/cmp_luasnip'
      Plug 'L3MON4D3/LuaSnip'
      Plug 'jose-elias-alvarez/null-ls.nvim'
    else
      Plug 'neoclide/coc.nvim', {'branch': 'release'}
    endif
  else
    Plug 'neoclide/coc.nvim', {'branch': 'release'} " use coc vith vi
  endif

  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-commentary'

  Plug 'pgr0ss/vim-github-url'
  Plug 'joshdick/onedark.vim'

call plug#end()
