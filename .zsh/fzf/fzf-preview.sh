#!/usr/bin/env bash
#
if [ -z "$1" ]; then
  exit 1
fi

IFS=':' read -r -a INPUT <<< "$1"
FILE=${INPUT[0]}
CENTER=${INPUT[1]}

if [[ "$1" =~ ^[A-Za-z]:\\ ]]; then
  FILE=$FILE:${INPUT[1]}
  CENTER=${INPUT[2]}
fi

if [[ -n "$CENTER" && ! "$CENTER" =~ ^[0-9] ]]; then
  exit 1
fi
CENTER=${CENTER/[^0-9]*/}

FILE="${FILE/#\~\//$HOME/}"

if [ -z "$CENTER" ]; then
  CENTER=0
fi

if [[ -d $FILE ]]; then
  tree -C "$FILE"
  exit $?
elif [[ -f $FILE ]]; then
  bat --style=numbers --color=always --pager=never \
      --highlight-line=$CENTER -- "$FILE"
  exit $?
else
  echo "$FILE"
  exit $?
fi

