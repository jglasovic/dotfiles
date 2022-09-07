# Vim configuration

## `vimrc`

I'm actively using neovim but this configuration is also compatible with vim.

My configuration uses [vim-plug](https://github.com/junegunn/vim-plug) for managing plugins

Configuration files are in two main directories:

- `rcfiles` - base vim config files
- `rcplugins` - plugins config files

## `rcfiles`

Base vim config files

### `settings.vim`

- clipboard unnamedplus
- no backup, no swap file
- incremental, case-insensitive search
- fold indent, 2 spaces, no tabs
- vertical split goes right, horizontal split goes up
- relative line numbers, insert-mode normal line numbers
- ripgrep, undo history
- if missing, creating dirs on buf save

### `mappings.vim`

- arrow keys for movement are disabled!
- `<Space>` - leader key
- `;;` - exiting insert and terminal mode
- `<CR>` - toggle highlighting after search
- `<C-s>` - save
- `<C-w>` - delete buffer
- `<C-q>` - :q
- `<C-{h/j/k/l}>` - jumping around splits in vim and tmux [vim-tmux-navigator](christoomey/vim-tmux-navigator)
- `<leader>v` - source vimrc
- `<leader>p` - search files
- `<leader>P` - search files content
- `<leader>b` - search buffers
- `<leader>w{h/j/k/l}` - opening new splits
- `<leader><leader>` - toggle between last open buffers
- `<leader>ln` - toggle line numbers
- `<leader>ic` - toggle invisible characters
- `<leader>ff` - fold/unfold current (non recursive, only one level)
- `<leader>FF` - fold/unfold recursive
- `<leader>fa` - close all folds
- `<leader>Fa` - open all folds
- `<leader>sl` - substitutions - line
- `<leader>sg` - substitutions - global
- `H` and `L` - jump to start/end of line
- `<A-{j/k}>` - move line(s) content down/up
- `<C-{arrow keys}` - resize splits

### `visual.vim`

- using [onedark.vim](https://github.com/joshdick/onedark.vim) colorscheme, dark background, no termguicolors (with this colorscheme, it looks nice to me without)
- cursorline in insert mode
- created custom statusline/bufferline in lua. (I couldn't find one light plugin so I created my own :) TODO: try [lightline](https://github.com/itchyny/lightline.vim))

### `functions.vim`

- Some useful functions like: `FindBuffers`, `CloseBuffers`, `HasBuffer`,...

## `rcplugins`

Plugin config files

### `netrw.vim` - File explorer

- `<leader>t` - open explorer in dir of the current buffer
- `<leader>T` - open explorer in `$PWD` dir

Mappings in explorer buf:

- `<Esc>` - close explorer
- `<leader>R` - refresh
- `h/l` - move directories up/down or open file
- `H` - back in history
- `.` - show/hide dotfiles

- `ff` - create file
- `d` - create directory
- `fr` - rename file/dir
- `D` - delete marked file(s)/dir(s) or the one under the cursor

- `<TAB>` - toggle mark on a file or dir
- `<S-TAB>` - remove all marks in a current dir
- `<leader><TAB>` - remove all marks
- `mt` - make target dir
- `fc` - copy marked file(s)
- `fC` - mark and copy one
- `fm` - move marked file(s)
- `fM` - mark and move one
- `fl` - show all marked files
- `ft` - show target dir
- `f;` - run external command on marked file(s)/dir(s)

- `bb` - create a bookmark
- `bd` - remove most recent bookmark
- `bj` - jump to the most recent bookmark

### `coc.vim` - [coc.nvim](https://github.com/neoclide/coc.nvim)

- `[g` - diagnostics prev
- `]g` - diagnostics next
- `gd` - go to definition
- `gt` - go to type definition
- `gi` - go to implementation
- `gr` - go to references
- `K` and `M` - show documentation (M = help or man)
- `<leader>,` - show all diagnostics
- `<leader>rn` - rename
- `<leader>.` - code action under cursor
- `<leader>ab` - code action all buffer
- `<leader>qf` - quick fix under cursor
- `<leader>cl` - code lens
- `<leader>[` - restart coc server

- `:Format` - format
- `:Fold` - fold
- `:OR` - organize imports
- `:Prettier` - prettier

### `nvim-lsp.lua`

A list of plugins to support lsp: [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig), [nvim-cmp](https://github.com/hrsh7th/nvim-cmp), [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp), [cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip), [LuaSnip](https://github.com/L3MON4D3/LuaSnip), and [null-ls.nvim](https://github.com/jose-elias-alvarez/null-ls.nvim)

If using `nvim` with `USE_LSP="true"`, `nvim` is not going to use `coc`, but instead it's going to use `nvim-lsp`
Mappings are the same as with `coc` (TODO: I have to fix some)

### `vim-fugitive.vim` - [vim-fugitive](https://github.com/tpope/vim-fugitive)

- `<leader>gs` - toggle git status
- `<leader>gb` - toggle git blame
- `<leader>gd` - toggle git diff
- `gl` - pick right in gitdiff
- `gh` - pick left in gitdiff

### `vim-github-url.vim` - [vim-github-url](https://github.com/pgr0ss/vim-github-url)

- `<leader>gy` - yank github url on current/selected line(s)

### Other plugins with default configs

- [fzf.vim](https://github.com/junegunn/fzf.vim)
- [vim-surround](https://github.com/tpope/vim-surround)
- [vim-commentary](https://github.com/tpope/vim-commentary)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [plenary](https://github.com/nvim-lua/plenary.nvim)
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)
- [poet-v](https://github.com/petobens/poet-v)
- [vimspector](https://github.com/puremourning/vimspector)
