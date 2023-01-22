# ZSH configuration

## `.zshrc`

Location of this file is in root of this repo. It sources `utils.sh` and all config files in `/config` directory.
I'm using zsh with vi-mode

## `utils.sh`

Contains some helpful functions for other scripts in `config` directory. In `.zshrc`, this file has to be sourced before other config scripts

## `config`

My custom zsh config files

### `aliases.sh`

Contains my sh aliases.

### `prompt.sh`

My custom prompt

### `load-nvm.sh`

ZSH hook for `nvm`. On `cd` automatically sets/installs(if missing) node version defined in `nvmrc` if file exists, otherwise sets a default version.

### `zsh-vi-mode.sh`

Override some vi-mode key bindings. Uses system clipboard

### `tmux-sessions-restore.sh`

Custom script for restoring tmux sessions. It requires `$TMUX_SESSIONS_CONFIG_PATH` to be set.

It's just a `json` config file. Example:

```json
{
  "sessions": [
    {
      "name": "My session",
      "windows": [
        {
          "name": "name 1",
          "path": "<path to 1>"
        },
        {
          "name": "name 2",
          "path": "<path to 2>"
        },
        {
          "name": "name 3",
          "path": "<path to 3>"
        }
      ]
    }
  ]
}
```

### `custom-scripts.sh`

Custom scripts for my everyday work.
