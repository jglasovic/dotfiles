#!/bin/zsh

## Aliases
alias vim="nvim"
alias s="git status"
alias cat="bat"
alias ls='eza --sort=type'
alias ll='eza --sort=type -al'
alias gu="git_merge_branch"
alias zshconf="vim $HOME/.zshrc"
alias so=". $HOME/.zshrc"
# https://github.com/pyenv/pyenv#homebrew-in-macos
alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'
