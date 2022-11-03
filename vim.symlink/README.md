# Vim configuration

## `vimrc`

I'm actively using neovim but this configuration is also compatible with vim.

My configuration uses [vim-plug](https://github.com/junegunn/vim-plug) for managing plugins

Configuration files are in two main directories:

- `rcfiles` - base vim config files
- `rcplugins` - plugins config files
- `ftplugins` - filetype specific config files

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
- `<C-s>` - write
- `<C-w>` - delete buffer
- `<C-q>` - :q
- `<C-{h/j/k/l}>` - jumping around splits in vim and tmux [vim-tmux-navigator](christoomey/vim-tmux-navigator)
- `<leader>v` - source vimrc
- `<leader>f` - find files
- `<leader>F` - find in files
- `<leader>d` - find dirs
- `<leader>b` - find buffers
- `<leader>w{h/j/k/l}` - opening new splits
- `<leader><leader>` - toggle between last opened buffers
- `<leader>ln` - toggle line numbers
- `<leader>ic` - toggle invisible characters
- `<leader>h` - toggle highlighting after search
- `<leader>sl` - substitutions - line
- `<leader>sg` - substitutions - global
- `Q` - playback of the recording that was put into the q register
- `<A-{j/k}>` - move line(s) content down/up
- `<C-{arrow keys}` - resize splits

### `visual.vim`

- using [onedark.vim](https://github.com/joshdick/onedark.vim) colorscheme, dark background, no termguicolors (with this colorscheme, it looks nice without)
- cursorline in insert mode
- simple statusline and tabline

### `functions.vim`

- Some useful functions like: `FindBuffers`, `CloseBuffers`, `HasBuffer`,...

## `rcplugins`

Plugin config files

### `netrw.vim` - File explorer

- `<leader>e` - open explorer in dir of the current buffer
- `<leader>E` - open explorer in `$PWD` dir

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

### `vim-fugitive.vim` - [vim-fugitive](https://github.com/tpope/vim-fugitive)

- `<leader>gs` - git status
- `<leader>gb` - git blame
- `<leader>gd` - diff for a current file
- `<leader>gD` - diff history
- `<leader>gc` - closing all fugitive buffers
- `gl` - pick right in gitdiff
- `gh` - pick left in gitdiff

- `:DiffHistory <optional args [max: 2]: branches or commit hashes>` - diff history if args are not provided.

  - if single arg is provided, example: `DiffHistory main` - diff between current branch and `main`
  - if both args are provided, example: `DiffHistory main test-branch-1` - diff between `main` and `test-branch-1`
  - Commit hashes could also be provided (also in any combination with branches): `DiffHistory 0c29b5f b929329`, `DiffHistory main b929329`

    - `]q` - next changes
    - `[q` - previous changes

  - `:Git log` then selecting a commit, `DiffHistory` is going to show all changes in that commit

### `vim-github-url.vim` - [vim-github-url](https://github.com/pgr0ss/vim-github-url)

- `<leader>gy` - yank github url on current/selected line(s)

### `vim-dadbod` and `vim-dadbod-ui` - [vim-dadbod](https://github.com/tpope/vim-dadbod) & [vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui)

- `:DB` - Toggle DB client
- `dbout` buffer:
  - `w` - move cursor to the right column
  - `b` - move cursor to the left column
  - `<C-]>` - cursor on column, jump to reference table row

### Other plugins with default configs

- [fzf.vim](https://github.com/junegunn/fzf.vim)
- [vim-surround](https://github.com/tpope/vim-surround)
- [vim-commentary](https://github.com/tpope/vim-commentary)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [poet-v](https://github.com/petobens/poet-v)
