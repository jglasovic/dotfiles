# Jure's dotfiles

Thanks to [Josh Dick](https://github.com/joshdick)

## Installation:

TODO: will add

## Vim configuration:

### `vimrc`

My configuration uses [vim-plug](https://github.com/junegunn/vim-plug) for managing plugins

- configuration files are in two main directories:

  - `rcfiles` - base vim configs
  - `rcplugins` - specific plugin configs

### `rcfiles`

#### `settings`

- clipboard unnamedplus
- no backup, no swap file
- spell lang en_us
- incremental, case-insensitive search
- fold indent, 2 spaces, no tabs
- vertical split goes right, horizontal split goes up
- relative line numbers, insert-mode normal line numbers
- ripgrep, undo history
- if missing, creating dirs on buf save

#### `mappings`

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
- `<leader><leader>` - switch between two recent buffers
- `<leader>ln` - toggle line numbers
- `<leader>ic` - toggle invisible characters
- `<leader>ff` - fold/unfold current (non recursive, only one level)
- `<leader>FF` - fold/unfold recursive
- `<leader>fa` - close all folds
- `<leader>Fa` - open all folds
- `<leader>sl` - substitutions - line
- `<leader>sg` - substitutions - global
- `<leader>sc` - toggle spell check
- `<leader>wg` - spell check - mark word as good
- `<leader>wb` - spell check - fix bad word
- `H` and `L` - jump to start/end of line
- `<A-{j/k}>` - move line(s) content down/up
- `<C-{arrow keys}` - resize splits

#### `visual`

- using [onedark.vim](https://github.com/joshdick/onedark.vim) colorscheme, dark background, no termguicolors (with this colorscheme, it looks nice to me without)
- cursorline in insert mode
- created custom statusline/bufferline in lua. (I have spent some time trying to find some light plugin but couldn't, so I created my own :) maybe this TODO: [lightline](https://github.com/itchyny/lightline.vim))

#### `functions`

- some useful functions like: `FindBuffers`, `CloseBuffers`, `HasBuffer`,...

### `rcplugins`

#### `netrw`

File explorer

- `<leader>t` - open explorer in dir of the current buffer
- `<leader>T` - open explorer in $PWD dir

Mappings in explorer buf:

- `<Esc>` - close explorer
- `<leader>R` - refresh
- `<TAB>` - toggle mark on a file or dir
- `<S-TAB>` - remove all marks in a current dir
- `<leader><TAB>` - remove all marks
- `h/l` - move directories up/down or open file
- `H` - back in history
- `ff` - file create
- `FF` - delete file(s) and dirs (TODO: need to fix this)
- `fr` - file rename
- `fd` - file delete
- `fc` - copy marked file(s)
- `fC` - mark and copy one
- `fm` - move marked file(s)
- `fM` - mark and move one
- `fl` - show all marked files
- `ft` - show target dir
- `f;` - run external command on marked file(s)

- `bb` - create a bookmark
- `bd` - remove most recent bookmark
- `bj` - jump to the most recent bookmark

#### `coc`

[coc.nvim](https://github.com/neoclide/coc.nvim)

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

#### `nvim-lsp`

A list of plugins to support lsp: [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig), [nvim-cmp](https://github.com/hrsh7th/nvim-cmp), [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp), [cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip), [LuaSnip](https://github.com/L3MON4D3/LuaSnip), and [null-ls.nvim](https://github.com/jose-elias-alvarez/null-ls.nvim)

If using `nvim` with `USE_LSP="true"`, `nvim` is not going to use `coc`, but instead it's going to use `nvim-lsp`
Mappings are the same as with `coc` (TODO: I have to fix some)

#### `vim-fugitive`

[vim-fugitive](https://github.com/tpope/vim-fugitive)

- `<leader>gs` - toggle git status
- `<leader>gb` - toggle git blame
- `<leader>gd` - toggle git diff
- `<leader>gl` - pick right in gitdiff
- `<leader>gh` - pick left in gitdiff

#### `vim-github-url`

[vim-github-url](https://github.com/pgr0ss/vim-github-url)

- `<leader>gy` - yank github url on current/selected line(s)
