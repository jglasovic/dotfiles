#!/bin/bash

SELF_PATH=$(readlink -f "$0")
SELF_DIR=$(dirname "$SELF_PATH")

source "$SELF_DIR/fzf-utils.sh"

if [ -z "$1" ]; then
    exit 1
fi

{
  read -r FILE
  read -r LINE
  read -r COLUMN
} <<< "$( parse_fzf_input $1 )"

eval "$EDITOR '+call cursor($LINE, $COLUMN)' $FILE"

