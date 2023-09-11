#!/bin/zsh

set -o vi
setopt TRANSIENT_RPROMPT

#  VI Mode cursor style
vim_ins_mode='-I-'
vim_cmd_mode=''
vim_mode="$vim_ins_mode"

function set_mode {
  RPROMPT="$vim_mode"
  zle && zle reset-prompt
}
function zle-keymap-select {
  vim_mode="${${KEYMAP/vicmd/${vim_cmd_mode}}/(main|viins)/${vim_ins_mode}}"
  set_mode
}
function zle-line-init {
  vim_mode="$vim_ins_mode"
  set_mode
}
function TRAPINT() {
  vim_mode="$vim_ins_mode"
  set_mode
  return $(( 128 + $1 ))
} 
zle -N zle-line-init
zle -N zle-keymap-select
set_mode
# ----------

zle_highlight+=(paste:none)

### use system clipboard
function pbpaste_to_cutbuffer() {
  CUTBUFFER=`pbpaste -Prefer txt`;
}

function pbcopy_cutbuffer() {
  echo "$CUTBUFFER" | pbcopy
}
###

# override to use system clipboard
function vi_yank(){
  zle .vi-yank
  pbcopy_cutbuffer
}

function vi_yank_whole_line(){
  zle .vi-yank-whole-line
  pbcopy_cutbuffer
}

function vi_delete() {
  zle .vi-delete
  pbcopy_cutbuffer
}

function vi_put_after(){
  pbpaste_to_cutbuffer
  zle .vi-put-after
}

function vi_put_before(){
  pbpaste_to_cutbuffer
  zle .vi-put-before
}

function put_replace_selection(){
  pbpaste_to_cutbuffer
  zle .put-replace-selection
}

zle -N vi-yank vi_yank
zle -N vi-yank-whole-line vi_yank_whole_line
zle -N vi-put-after vi_put_after
zle -N vi-put-before vi_put_before
zle -N vi-delete vi_delete
zle -N put-replace-selection put_replace_selection

# keybindings
bindkey -M vicmd 'H' beginning-of-line
bindkey -M vicmd 'L' end-of-line

bindkey -M vicmd 'k' up-line-or-beginning-search
bindkey -M vicmd 'j' down-line-or-beginning-search

bindkey -M vicmd '^[[A' up-line-or-beginning-search
bindkey -M vicmd '^[[B' down-line-or-beginning-search
bindkey -M viins '^[[A' up-line-or-beginning-search
bindkey -M viins '^[[B' down-line-or-beginning-search

bindkey -M vicmd '^E' edit-command-line
bindkey -M viins '^E' edit-command-line

# Fix backspace: https://github.com/spaceship-prompt/spaceship-prompt/issues/91#issuecomment-327996599
bindkey "^?" backward-delete-char
