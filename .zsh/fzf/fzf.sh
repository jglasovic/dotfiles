#!/bin/bash

# Define ignore patterns
# Comma-separated patterns:
EXCLUDE_CUSTOM=".git"
# Ignore opts
IGNORE_OPTS="--ignore-vcs"
# ------------------------
SELF_PATH=$(readlink -f "$0")
SELF_DIR=$(dirname "$SELF_PATH")

source "$HOME/.fzf.zsh"
source "$SELF_DIR/fzf-git.sh"


if ! [ -z "$TMUX" ]; then
  export FZF_TMUX=1
  alias fzf="fzf-tmux"
  tmux_version=$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p") 
  # tmux version 3.2 and above is supporting popup win
  if [ "$(echo "$tmux_version >= 3.2" | bc)" = 1 ]; then
    # Use tmux popup window
    export FZF_TMUX_OPTS='-p 80%,60%'
    alias fzf="fzf-tmux $FZF_TMUX_OPTS"
  fi
fi


FD_IGNORE_OPTS="$IGNORE_OPTS --exclude '$EXCLUDE_CUSTOM'"
FD_BASE_OPTS="--ignore-case --follow --hidden"

FD_FILE_CMD="fd -t f $FD_BASE_OPTS"
FD_DIR_CMD="fd -t d $FD_BASE_OPTS"


export FZF_DEFAULT_COMMAND="$FD_FILE_CMD $FD_IGNORE_OPTS"
export FZF_DEFAULT_OPTS=" 
  --reverse
  --bind change:top
  --bind 'ctrl-p:toggle-preview'
  --bind 'ctrl-s:toggle-sort'
  --bind 'ctrl-y:execute-silent(echo -n {} | pbcopy)'
  --bind 'ctrl-f:preview-page-down'
  --bind 'ctrl-b:preview-page-up'
  --bind 'ctrl-u:preview-half-page-up'
  --bind 'ctrl-d:preview-half-page-down'"

export FZF_CTRL_T_COMMAND="$FD_FILE_CMD $FD_IGNORE_OPTS"
export FZF_CTRL_T_OPTS="--bind 'ctrl-r:reload($FD_FILE_CMD)' --prompt $(pwd)/ --preview '$SELF_DIR/fzf-preview.sh {}'"

export FZF_ALT_C_COMMAND="$FD_DIR_CMD $FD_IGNORE_OPTS"
export FZF_ALT_C_OPTS="--bind 'ctrl-r:reload($FD_DIR_CMD)' --prompt $(pwd)/ --preview '$SELF_DIR/fzf-preview.sh {}'"

RG_IGNORE_OPTS="$IGNORE_OPTS --glob '!{$EXCLUDE_CUSTOM}'"
RG_BASE_OPTS="--column --line-number --no-heading --color=always --hidden --smart-case" 
RG_CMD="rg $RG_BASE_OPTS $RG_IGNORE_OPTS"

__fzf_rg(){
  fzf --ansi \
    --disabled \
    --multi \
    --delimiter ":" \
    --query "" \
    --prompt "Rg> " \
    --bind "start:reload:$RG_CMD -- ''" \
    --bind "change:reload:$RG_CMD -- {q} || true" \
    --bind "enter:become($SELF_DIR/fzf-editor.sh {+})" \
    --preview-window '+{2}-/2' \
    --preview "$SELF_DIR/fzf-preview.sh {}"
}

fzf-rg-widget() { 
  local result=$(__fzf_rg)
  zle reset-prompt
  LBUFFER+=$result 
}
zle -N fzf-rg-widget

# unbind default fzf keymapping
bindkey -rM emacs '^T'
bindkey -rM vicmd '^T'
bindkey -rM viins '^T' 
bindkey -rM emacs '\ec'
bindkey -rM vicmd '\ec'
bindkey -rM viins '\ec'

# bind my own keys (same as in vim)
bindkey -M vicmd ' f' fzf-file-widget
bindkey -M vicmd ' r' fzf-rg-widget
bindkey -M vicmd ' F' fzf-cd-widget
