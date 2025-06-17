#!/bin/bash

# Define ignore patterns
# Comma-separated patterns:
EXCLUDE_CUSTOM=".git"
# ------------------------
SELF_PATH=$(readlink -f "$0")
SELF_DIR=$(dirname "$SELF_PATH")

source "$SELF_DIR/fzf-utils.sh"
export FZF_COLORS=$(_get_fzf_colors)
export FZF_DEFAULT_OPTS=" 
  --tmux 80%,60%
  --reverse
  --bind change:top
  --bind 'ctrl-p:toggle-preview'
  --bind 'ctrl-s:toggle-sort'
  --bind 'ctrl-y:execute-silent(echo -n {} | pbcopy)'
  --bind 'ctrl-f:preview-page-down'
  --bind 'ctrl-b:preview-page-up'
  --bind 'ctrl-u:preview-half-page-up'
  --bind 'ctrl-d:preview-half-page-down'
  $FZF_COLORS"

source "$HOME/.fzf.zsh"
source "$SELF_DIR/fzf-gh.sh"
source "$SELF_DIR/fzf-git.sh"
source "$SELF_DIR/fzf-docker.sh"

FD_BASE_OPTS="--ignore-case --follow --hidden --exclude '$EXCLUDE_CUSTOM'"
FD_FILE_CMD="fd $FD_BASE_OPTS -t f" 
FD_DIR_CMD="fd $FD_BASE_OPTS -t d"

export FZF_DEFAULT_COMMAND="$FD_FILE_CMD"

# TODO: fix not working for both
toggle_vsc_ignore="transform:[[ {fzf:prompt} =~ \(--no-ignore\) ]] && \
echo \"change-prompt(\${FZF_PROMPT#\(--no-ignore\)})+reload(eval \$FZF_DEFAULT_COMMAND)\" || \
echo \"change-prompt((--no-ignore)\$FZF_PROMPT)+reload(eval \"\$FZF_DEFAULT_COMMAND --no-ignore\")\""
toggle_files_dirs="transform:[[ {fzf:prompt} =~ \(-d\) ]] && \
echo \"change-prompt(\${FZF_PROMPT#\(-d\)})+reload(eval \$FZF_DEFAULT_COMMAND)\" || \
echo \"change-prompt((-d)\$FZF_PROMPT)+reload(eval \"\${FZF_DEFAULT_COMMAND%%\" -t f\"} -t d\")\""

export FD_CMD_OPTS="--bind='start:transform-prompt:echo \$(sed \"s/\(.\)[^/]*\//\1\//g\" <<< \"\${PWD//\$HOME/~}\")/' \
--preview '$SELF_DIR/fzf-preview.sh {}' \
--bind='ctrl-r:$toggle_vsc_ignore' \
--bind='ctrl-o:$toggle_files_dirs'"

export FZF_CTRL_T_COMMAND="$FD_FILE_CMD"
export FZF_CTRL_T_OPTS="$FD_CMD_OPTS"

export FZF_ALT_C_COMMAND="$FD_DIR_CMD"
export FZF_ALT_C_OPTS="$FD_CMD_OPTS"

RG_BASE_OPTS="--column --line-number --no-heading --color=always --hidden --smart-case --glob '!{$EXCLUDE_CUSTOM}'" 
# exporting also for vim to use it
export RG_CMD="rg $RG_BASE_OPTS"
export rg_toggle_vsc_ignore="transform:[[ {fzf:prompt} =~ \(--no-ignore\) ]] && \
echo \"change-prompt(\${FZF_PROMPT#\(--no-ignore\) })+reload($RG_CMD -- {q} || :)\" || \
echo \"change-prompt((--no-ignore) \$FZF_PROMPT)+reload($RG_CMD --no-ignore -- {q} || :)\""
export rg_change="transform:[[ {fzf:prompt} =~ \(--no-ignore\) ]] && \
echo \"reload($RG_CMD --no-ignore -- {q} || :)\" || \
echo \"reload($RG_CMD -- {q} || :)\""

fzf_rg(){
  local selected=$(fzf --ansi \
    --disabled \
    --multi \
    --delimiter ":" \
    --query "$1" \
    --prompt "Rg> " \
    --bind "start:reload:$RG_CMD -- ''" \
    --bind "change:$rg_change" \
    --bind "ctrl-r:$rg_toggle_vsc_ignore" \
    --preview-window '+{2}-/2' \
    --preview "$SELF_DIR/fzf-preview.sh {}")
  "$SELF_DIR/fzf-editor.sh" "$selected"
}

fzf-rg-widget() { 
  local result=$(fzf_rg)
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
bindkey -M vicmd ' F' fzf-cd-widget
bindkey -M vicmd ' r' fzf-rg-widget
