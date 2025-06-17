#!/bin/bash

export FZF_DOCKER_LIST='docker ps'

local toggle_list_all="[[ ! {fzf:prompt} =~ all ]] && \
  echo \"change-prompt(Docker(all) > )+reload($FZF_DOCKER_LIST -a)\" || \
  echo \"change-prompt(Docker(running) > )+reload($FZF_DOCKER_LIST)\""

export FZF_DOCKER_LIST_OPTIONS="--ansi \
  --prompt 'Docker(running) > ' \
  --color='header:italic,label:blue' \
  --header-lines 1 \
  --header='CTRL-R (toggle running/all) ╱ CTRL-T (pick image value) \

  '\
  --bind='ctrl-t:become(echo -n \"image=true \" && echo {})' \
  --bind='ctrl-r:transform:$toggle_list_all'"

#####################################################################

_fzf_docker() { 
  local selected=$(
    FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS-} ${FZF_DOCKER_LIST_OPTIONS-}" \
    FZF_DEFAULT_COMMAND="$FZF_DOCKER_LIST" \
    fzf < "$TTY"
  )
  [[ "$selected" =~ "image=true" ]] && \
    echo $selected | awk '{print $3}' || \
    echo $selected | awk '{print $1}'
}


fzf-docker-widget() { 
  local result=$(_fzf_docker)
  zle reset-prompt
  LBUFFER+=$result
}

zle -N fzf-docker-widget
bindkey -M vicmd ' dp' fzf-docker-widget
