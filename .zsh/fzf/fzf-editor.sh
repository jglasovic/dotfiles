#!/bin/bash

SELF_PATH=$(readlink -f "$0")
SELF_DIR=$(dirname "$SELF_PATH")

source "$SELF_DIR/fzf-utils.sh"

{
  read -r FILE
  read -r LINE
  read -r COLUMN
} <<< "$( parse_fzf_input $1 )"

if [ -z "$TMUX" ]; then
  eval "$EDITOR '+call cursor($LINE, $COLUMN)' $FILE" < /dev/tty > /dev/tty
else
  tmux send-keys Enter
  tmux send-keys "$EDITOR '+call cursor($LINE, $COLUMN)' $FILE" Enter
fi

