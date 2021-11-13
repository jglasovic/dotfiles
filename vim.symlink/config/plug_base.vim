call plug#begin('~/.vim/plugged')
	Plug 'preservim/nerdtree'
	Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
	Plug 'junegunn/fzf', {'do': {-> fzf#install()}}
	Plug 'junegunn/fzf.vim'
	Plug 'hoob3rt/lualine.nvim'
	Plug 'tpope/vim-fugitive'
	Plug 'sheerun/vim-polyglot'
	"Plug 'neoclide/coc.nvim', {'branch': 'release'}  switched to nvim-lsp below
	Plug 'neovim/nvim-lspconfig'	
	Plug 'williamboman/nvim-lsp-installer'
	Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
call plug#end()
