#!/bin/zsh
## Jure Glasovic's .zshrc <https://github.com/jglasovic>

## Reset PATH
PATH=$(env -i bash --login --norc -c 'echo $PATH')

LC_ALL="en_US.UTF-8"
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

export DENO_ROOT="$HOME/.deno"
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
export PHP_ROOT="$BREW_PREFIX/Cellar/php/8.1.2"
export OPENSSL_ROOT="$BREW_PREFIX/opt/openssl@3"
export GPG_ROOT="$BREW_PREFIX/opt/gnupg@2.2"
export CURL_ROOT="$BREW_PREFIX/opt/curl"
export ANDROID_TOOLS_PATH="$ANDROID_HOME/build-tools/34.0.0:$ANDROID_HOME/platform-tools"

export LDFLAGS="-L$BREW_PREFIX/opt/zlib/lib -L$BREW_PREFIX/opt/bzip2/lib -L$BREW_PREFIX/opt/openssl@3/lib -L$BREW_PREFIX/opt/curl/lib"
export CPPFLAGS="-I$BREW_PREFIX/opt/zlib/include -I$BREW_PREFIX/opt/bzip2/include -I$BREW_PREFIX/opt/openssl@3/include -I$BREW_PREFIX/opt/curl/include"
export PKG_CONFIG_PATH="$BREW_PREFIX/opt/openssl@3/lib/pkgconfig:$BREW_PREFIX/opt/curl/lib/pkgconfig"

## rustup
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

## export path
export PATH="$OPENSSL_ROOT/bin":\
"$CURL_ROOT/bin":\
"$PHP_ROOT/bin":\
"$PYENV_ROOT/bin":\
"$POETRY_ROOT/bin":\
"$DENO_ROOT/bin":\
"$POSTGRES_ROOT/bin":\
"$MYSQL_ROOT/bin":\
"$GPG_ROOT/bin":\
"$SBIN_PATH":\
"$CORE_UTILS_PATH":\
"$ANDROID_TOOLS_PATH":\
"$PATH"

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
