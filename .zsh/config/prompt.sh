#!/bin/zsh

prompt_segment() {
  local fg
  [[ -n $1 ]] && fg="%F{$1}" || fg="%f"
  echo -n "%{$fg%}"
  [[ -n $2 ]] && echo -n $2
}


prompt_end() {
  prompt_segment "2" " %B$%b"
  echo -n "%{%k%}"
  echo -n "%{%f%}"
}

prompt_context() {
  if [[ "$USERNAME" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment default "%(!.%{%F{yellow}%}.)%n@%m"
  fi
}

prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi

  if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]]; then
    local ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"

    # check mode
    local repo_path=$(git rev-parse --git-dir 2>/dev/null)
    local mode
    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi
    # Check changes
    ###############################################################################
    # ! git diff-index --cached --quiet HEAD      # fastest staged-changes test   #
    # ! git diff-files --quiet                    # fastest unstaged-changes test #
    # ! git diff-index --quiet          HEAD      # fastest any-changes test      #
    # stdbuf -oL git ls-files -o | grep -qs .     # fastest untracked-files test  #
    # git rev-parse -q --verify refs/stash >&-    # fastest any-stash test        #
    ###############################################################################
    local dirty=""
    if ! git diff-index --cached --quiet HEAD; then
      dirty="$dirty*"
    fi
    if ! git diff-files --quiet; then 
      dirty="$dirty±"
    fi
    if [[ ! $dirty ]]; then
      prompt_segment 39
    else
      prompt_segment yellow
      dirty=" $dirty"
    fi

    echo -n "(${${ref:gs/%/%%}/refs\/heads\//}${dirty}${mode})"
    prompt_segment default
  fi
}


prompt_dir() {
  prompt_segment green ' %~'
}

prompt_virtualenv() {
  if [ "$VIRTUAL_ENV" != "" ]; then
    prompt_segment cyan "(${VIRTUAL_ENV:t:gs/%/%%})"
  fi
}
prompt_status() {
  local -a symbols

  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘ $RETVAL"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && prompt_segment default "$symbols"
}

prompt_aws() {
  [[ -z "$AWS_PROFILE" || "$SHOW_AWS_PROMPT" = false ]] && return
  case "$AWS_PROFILE" in
    *prod*) prompt_segment red  "(AWS: ${AWS_PROFILE:gs/%/%%})" ;;
    *) prompt_segment yellow "(AWS: ${AWS_PROFILE:gs/%/%%})" ;;
  esac
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_virtualenv
  prompt_aws
  prompt_context
  prompt_dir
  prompt_git
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '

