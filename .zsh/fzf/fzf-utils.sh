#!/bin/bash

_get_fzf_colors() {
  # onedark colors
  local fg='#565c64'
  local bg='#000000'
  local hl='#5f87af'
  local _fg='#b6bdca' 
  local _bg='#000000'
  local _hl='#d7005f'
  local info='#afaf87'
  local prompt='#61afef'
  local pointer='#af5fff'
  local marker='#87ff00'
  local spinner='#af5fff'
  local header='#87afaf'

  echo "--color=fg:$fg,bg:$bg,hl:$hl
        --color=fg+:$_fg,bg+:$_bg,hl+:$_hl
        --color=info:$info,prompt:$prompt,pointer:$pointer
        --color=marker:$marker,spinner:$spinner,header:$header"
}

parse_fzf_input(){
  if [ -z "$1" ]; then
    exit 1
  fi

  IFS=':' read -r -a INPUT <<< "$1"
  FILE=${INPUT[0]}
  LINE=${INPUT[1]}
  COLUMN=${INPUT[2]}

  if [[ "$1" =~ ^[A-Za-z]:\\ ]]; then
    FILE=$FILE:${INPUT[1]}
    LINE=${INPUT[2]}
    COLUMN=${INPUT[3]}
  fi

  FILE="${FILE/#\~\//$HOME/}"
  LINE=${LINE/[^0-9]*/}
  COLUMN=${COLUMN/[^0-9]*/}

  if [ -z "$LINE" ]; then
    LINE=0
  fi

  if [ -z "$COLUMN" ]; then
    COLUMN=0
  fi

  echo "$FILE"
  echo "$LINE"
  echo "$COLUMN"
}

