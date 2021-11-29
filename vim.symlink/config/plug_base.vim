call plug#begin('~/.vim/plugged')
	Plug 'preservim/nerdtree'
	Plug 'Xuyuanp/nerdtree-git-plugin'
	Plug 'junegunn/fzf', {'do': {-> fzf#install()}}
	Plug 'junegunn/fzf.vim'
	Plug 'hoob3rt/lualine.nvim'
"	Plug 'vim-airline/vim-airline'
	Plug 'tpope/vim-fugitive'
	Plug 'mhinz/vim-signify'
	Plug 'sheerun/vim-polyglot'
	Plug 'whatyouhide/vim-gotham'
	Plug 'christoomey/vim-tmux-navigator'
	Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
	Plug 'neoclide/coc.nvim', {'branch': 'release'} " upgrading to nativ lsp, need more time :)  
"	Plug 'neovim/nvim-lspconfig'
"	Plug 'williamboman/nvim-lsp-installer'
	Plug 'petobens/poet-v'
call plug#end()
