#!/bin/zsh
## Jure Glasovic's .zshrc <https://github.com/jglasovic>

## Reset PATH
PATH=$(env -i bash --login --norc -c 'echo $PATH')

# export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
ENABLE_CORRECTION="true"
HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000
SAVEHIST=1000
DEFAULT_USER="$USER"
# TERM=xterm

## editor
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi
export VISUAL=$EDITOR

## ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id

export PYENV_ROOT="$HOME/.pyenv"
export POETRY_ROOT="$HOME/.local"


eval "$(/opt/homebrew/bin/brew shellenv)"
BREW_PREFIX="$(brew --prefix)"
export ANDROID_HOME="$BREW_PREFIX/share/android-commandlinetools"
export PGDATA="$BREW_PREFIX/var/postgres"
export SBIN_PATH="$BREW_PREFIX/sbin"
export CORE_UTILS_PATH="$BREW_PREFIX/opt/coreutils/libexec/gnubin"
export POSTGRES_ROOT="$BREW_PREFIX/opt/postgresql@15"
export MYSQL_ROOT="$BREW_PREFIX/mysql"
export PHP_ROOT="$BREW_PREFIX/opt/php@7.4"
export RUBY_ROOT="$BREW_PREFIX/opt/ruby"
# /opt/homebrew/opt/php@7.4/bin
export OPENSSL_ROOT="$BREW_PREFIX/opt/openssl@3"
export GPG_ROOT="$BREW_PREFIX/opt/gnupg@2.2"
export CURL_ROOT="$BREW_PREFIX/opt/curl"
export ANDROID_TOOLS_PATH="$ANDROID_HOME/build-tools/34.0.0:$ANDROID_HOME/platform-tools"
export LLVM_ROOT="$BREW_PREFIX/opt/llvm"

export LDFLAGS="-L$LLVM_ROOT/lib -L$BREW_PREFIX/opt/zlib/lib -L$BREW_PREFIX/opt/bzip2/lib -L$BREW_PREFIX/opt/openssl@3/lib -L$BREW_PREFIX/opt/curl/lib -L/opt/homebrew/opt/mysql@8.4/lib"
export CPPFLAGS="-I$LLVM_ROOT/include -I$BREW_PREFIX/opt/zlib/include -I$BREW_PREFIX/opt/bzip2/include -I$BREW_PREFIX/opt/openssl@3/include -I$BREW_PREFIX/opt/curl/include -I/opt/homebrew/opt/mysql@8.4/include"
export PKG_CONFIG_PATH="$BREW_PREFIX/opt/openssl@3/lib/pkgconfig:$BREW_PREFIX/opt/curl/lib/pkgconfig:/opt/homebrew/opt/mysql@8.4/lib/pkgconfig"

# ## rustup
source "$HOME/.cargo/env"
## brew
FPATH="$BREW_PREFIX/share/zsh/site-functions:${FPATH}"
## omz
export ZSH="$HOME/.oh-my-zsh"
source "$ZSH/oh-my-zsh.sh"
##  pyenv
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
# fnm
eval "$(fnm env --use-on-cd)"

GOBIN="$(go env GOPATH)/bin"
## export path
PATH="$OPENSSL_ROOT/bin":\
"$RUBY_ROOT/bin":\
"$LLVM_ROOT/bin":\
"$CURL_ROOT/bin":\
"$PHP_ROOT/bin":\
"$PHP_ROOT/sbin":\
"$PYENV_ROOT/bin":\
"$POETRY_ROOT/bin":\
"$POSTGRES_ROOT/bin":\
"$MYSQL_ROOT/bin":\
"$GPG_ROOT/bin":\
"$SBIN_PATH":\
"$CORE_UTILS_PATH":\
"$ANDROID_TOOLS_PATH":\
"$PATH"

export PATH="$(gem environment gemdir)/bin":"$HOME/work/indigo/dev-tools/bin":$PATH

export PATH="/opt/homebrew/opt/mysql@8.4/bin:$PATH"

# source utils
source "$HOME/.zsh/utils.sh"
# source scripts
for script in `find $HOME/.zsh/config/ -type f -maxdepth 1 -mindepth 1`; do
  source "$script"
done
# source fzf
source "$HOME/.zsh/fzf/fzf.sh"
# use bat for man command output
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# disabling pyenv appending venv in prompt, handling that below
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
# fix for python keyring
export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring

. "/Users/jurepc/.deno/env"


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/jurepc/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/jurepc/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/jurepc/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/jurepc/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

