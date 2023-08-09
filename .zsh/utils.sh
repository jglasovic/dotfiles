#!/bin/bash

print_red() {
  echo "\e[95m$1\e[0m"
}

check_file_exists() {
  [ -f "$1" ]
}

variable_exists() {
  [ -n "$1" ]
}

command_exists() {
  type "$1" &> /dev/null
}

error() {
  print_red "$1" 1>&2
  exit 1
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

