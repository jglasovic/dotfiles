#!/bin/bash

# Show a cheatsheet from https://cht.sh
cheat() {
  curl "https://cht.sh/$1" | bat
}

ensure_installed_global_npm_package() {
  npm list -g "$1" || npm i -g "$1"
}

git_merge_branch() {
  if ! variable_exists $1; then
    echo "Missing branch!"
    return 1
  fi
  git checkout "$1"
  if [ $? != 0 ]; then
    return "$?"
  fi
  git pull
  git checkout -
  git merge "$1"
}
