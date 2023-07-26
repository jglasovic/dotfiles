#!/bin/bash

check_file_exists() {
  [ -f "$1" ]
}

print_red() {
  echo "\e[95m$1\e[0m"
}

variable_exists() {
  [ -n "$1" ]
}

command_exists() {
  type "$1" &> /dev/null
}

error() {
  echo "$1" 1>&2
  exit 1
}

# Show a cheatsheet from https://cht.sh
cheat() {
  curl "https://cht.sh/$1" | bat
}

is_app_running() {
  pgrep -xq "$1"; 
  [ $? = 0 ]
}

set_symlink() {
  path="$1"
  symlink_path="$2"
  should_overwrite_all="$3"
  if [ ! -e "$symlink_path" ] || [ "$should_overwrite_all" = "1" ]; then
    echo "will be created $path $symlink_path $should_overwrite_all"
    rm -rf "$symlink_path"
    ln -sv "$path" "$symlink_path"
  fi
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
