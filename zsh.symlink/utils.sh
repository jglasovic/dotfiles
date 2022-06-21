#!/bin/sh

function check-file-exists(){
  [ -f "$1" ]
}

function print-red(){
  echo "\e[95m$1\e[0m"
}

function variable_exists(){
  [ -n "$1" ]
}

function command_exists() {
  type "$1" &> /dev/null ;
}

function error(){
  echo $1 1>&2
  exit 1
}

# Show a cheatsheet from https://cht.sh
function cheat() {
  curl "https://cht.sh/$1"
}

function is_app_running(){
  pgrep -xq "$1"; 
  [[ $? == 0 ]]
}

function ensure_installed_global_npm_package(){
  npm list -g "$1" || npm i -g "$1"
}
