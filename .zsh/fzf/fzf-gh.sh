#!/bin/bash

export FZF_GH_PRS_LIST='GH_FORCE_TTY=90% gh pr list --limit 100'

local toggle_open_close_pr="[[ ! {fzf:prompt} =~ open ]] && \
  echo \"change-prompt(PR (open) > )+reload($FZF_GH_PRS_LIST)\" || \
  echo \"change-prompt(PR (closed) > )+reload($FZF_GH_PRS_LIST -s closed)\""

export FZF_GH_PRS_LIST_OPTIONS="--ansi \
  --prompt 'PR (open) > ' \
  --preview-window down,border-top,50% \
  --color='header:italic,label:blue' \
  --preview 'GH_FORCE_TTY=100% gh pr view {1}' \
  --header-lines 4 \
  --bind='ctrl-t:become(echo -n \"checkout=true \" && echo {})' \
  --bind='ctrl-r:transform:$toggle_open_close_pr' \
  --bind='ctrl-o:execute-silent(gh pr view {1} -w)'"

#####################################################################

_fzf_git_check() {
  git rev-parse HEAD > /dev/null 2>&1 && return

  [[ -n $TMUX ]] && tmux display-message "Not in a git repository"
  return 1
}

_fzf_gh_prs() { 
  _fzf_git_check || return
  local selected=$(FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS-} ${FZF_GH_PRS_LIST_OPTIONS-}" \
  FZF_DEFAULT_COMMAND="$FZF_GH_PRS_LIST" \
  fzf < "$TTY")
  [ -n "$selected" ] && $EDITOR "+call FZFGhPRWrapper('$selected')"
}


fzf-gh-prs-widget() { 
  _fzf_gh_prs
  zle reset-prompt
}

zle -N fzf-gh-prs-widget
bindkey -M vicmd ' gp' fzf-gh-prs-widget
