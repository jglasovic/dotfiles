call plug#begin('~/.vim/plugged')
" optional
	Plug 'preservim/nerdtree'
	Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
	Plug 'junegunn/fzf', {'do': {-> fzf#install()}}
	Plug 'junegunn/fzf.vim'
	Plug 'hoob3rt/lualine.nvim'
	Plug 'kyazdani42/nvim-web-devicons'
	Plug 'tpope/vim-fugitive'
	Plug 'sheerun/vim-polyglot'
	"Plug 'neoclide/coc.nvim', {'branch': 'release'}  switched to nvim-lsp below
	Plug 'neovim/nvim-lspconfig'
	Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
call plug#end()
