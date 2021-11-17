call plug#begin('~/.vim/plugged')
	Plug 'preservim/nerdtree'
	Plug 'Xuyuanp/nerdtree-git-plugin'
	Plug 'junegunn/fzf', {'do': {-> fzf#install()}}
	Plug 'junegunn/fzf.vim'
	Plug 'hoob3rt/lualine.nvim'
	Plug 'tpope/vim-fugitive'
"	Plug 'airblade/vim-gitgutter'
	Plug 'mhinz/vim-signify'
	Plug 'sheerun/vim-polyglot'
	Plug 'whatyouhide/vim-gotham'
	Plug 'christoomey/vim-tmux-navigator'
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	Plug 'petobens/poet-v'
	Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
call plug#end()
