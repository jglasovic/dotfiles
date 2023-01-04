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
  type "$1" &> /dev/null ;
}

error(){
  echo $1 1>&2
  exit 1
}

# Show a cheatsheet from https://cht.sh
cheat() {
  curl "https://cht.sh/$1"
}

is_app_running() {
  pgrep -xq "$1"; 
  [[ $? == 0 ]]
}

ensure_installed_global_npm_package() {
  npm list -g "$1" || npm i -g "$1"
}
