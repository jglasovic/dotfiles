
_fzf_git_check() {
  git rev-parse HEAD > /dev/null 2>&1 && return

  [[ -n $TMUX ]] && tmux display-message "Not in a git repository"
  return 1
}

export FZF_GH_PRS_LIST='GH_FORCE_TTY=100% gh pr list --limit 100'

transform="transform:[[ ! {fzf:prompt} =~ open ]] && \
  echo \"change-prompt(PR open> )+reload($FZF_GH_PRS_LIST)\" || \
  echo \"change-prompt(PR closed> )+reload($FZF_GH_PRS_LIST -s closed)\""

export FZF_GH_PRS_LIST_OPTIONS="--ansi \
  --prompt 'PR open>' \
  --preview-window down,border-top,50% \
  --color='header:italic:underline,label:blue' \
  --preview 'GH_FORCE_TTY=100% gh pr view {1}' \
  --header-lines 3 \
  --bind='ctrl-t:$transform'"

_gh_checkout_pr() {
  awk '{print $1}' \
  | xargs gh pr checkout
}

_fzf_gh_prs() { 
  _fzf_git_check || return
  local cmd="$FZF_GH_PRS_LIST"
  eval "$cmd" \
    | FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS-} ${FZF_GH_PRS_LIST_OPTIONS-}" fzf \
    | _gh_checkout_pr
}


fzf-gh-prs-widget() { 
  _fzf_gh_prs
  zle reset-prompt
}
zle -N fzf-gh-prs-widget

bindkey -M vicmd ' gp' fzf-gh-prs-widget
