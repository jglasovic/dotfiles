bindkey -v

zle_highlight+=(paste:none)

# reset prompt on mode change
function zle-keymap-select zle-line-init
{
    zle reset-prompt
    zle -R
}

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

zle -N zle-line-init
zle -N zle-keymap-select

# keybindings
bindkey -M vicmd 'H' beginning-of-line
bindkey -M vicmd 'L' end-of-line

bindkey -M vicmd 'k' up-line-or-beginning-search
bindkey -M vicmd 'j' down-line-or-beginning-search

bindkey -M vicmd '^[[A' up-line-or-beginning-search
bindkey -M vicmd '^[[B' down-line-or-beginning-search
bindkey -M viins '^[[A' up-line-or-beginning-search
bindkey -M viins '^[[B' down-line-or-beginning-search
# Fix backspace: https://github.com/spaceship-prompt/spaceship-prompt/issues/91#issuecomment-327996599
bindkey "^?" backward-delete-char

