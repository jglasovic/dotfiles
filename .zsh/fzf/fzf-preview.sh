#!/bin/bash

SELF_PATH=$(readlink -f "$0")
SELF_DIR=$(dirname "$SELF_PATH")

source "$SELF_DIR/fzf-utils.sh"

{
  read -r FILE
  read -r LINE
} <<< "$( parse_fzf_input $1 )"

if [[ -d $FILE ]]; then
  tree -C "$FILE"
  exit $?
elif [[ -f $FILE ]]; then
  bat --style=numbers,changes --color=always --pager=never \
      --highlight-line=$LINE -- "$FILE"
  exit $?
else
  echo "$FILE"
  exit $?
fi
