#!/bin/bash

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

  if [[ -n "$CENTER" && ! "$CENTER" =~ ^[0-9] ]]; then
    exit 1
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
