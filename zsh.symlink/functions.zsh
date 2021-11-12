
function check-file-exists(){
  [ -f "$1" ]
}

function print-c(){
  echo "\e[95m$1\e[0m"
}

function variable_exists(){
  [ -z "$1" ]
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

# set node version based on .nvmrc
function load-nvmrc() {
  if command_exists nvm ; then
	  local node_version="$(nvm version)"
	  local nvmrc_path="$(nvm_find_nvmrc)"

	  if [ -n "$nvmrc_path" ]; then
	    local nvmrc_node_version=$(nvm version "$(/bin/cat "${nvmrc_path}")")

	    if [ "$nvmrc_node_version" = "N/A" ]; then
	      nvm install
	    elif [ "$nvmrc_node_version" != "$node_version" ]; then
	      nvm use
	    fi
	  elif [ "$node_version" != "$(nvm version default)" ]; then
	    echo "Reverting to nvm default version"
	    nvm use default
	  fi
  else
    exit "Missing nvm command"
  fi
}

# aws credentials expiration
function get-aws-ceredentials-expiration(){
  local aws_credentials_path=~/.aws/credentials
  if check-file-exists $aws_credentials_path ; then
	  local x_security_token_expires=$1
	  while IFS=' = ' read key value
	  do
	    if [[ $key == \[*] ]]; then
		section=$key
	    elif [[ $value ]] && [[ $section == '[default]' ]]; then
		if [[ $key == 'x_security_token_expires' ]]; then
		   eval $x_security_token_expires=$value
		fi
	    fi
	  done < $aws_credentials_path
  else
	  exit "Missing $aws_credentials_path"
  fi
}

 # VPN check connection
 # requires VPN_CLIENT_APP and MY_VPN_IP
function check-vpn-connection(){
  print-c $VPN_CLIENT_APP
  print-c $MY_VPN_IP
  if [ ! variable_exists $VPN_CLIENT_APP ]  || [ ! variable_exists $MY_VPN_IP ]; then
    echo "VPN_CLIENT_APP and MY_VPN_IP are required!"
  else
    local openVpnFlag=0
    local publicIP=$(curl ifconfig.me)

    while [[ $MY_VPN_IP != $publicIP ]]; do
      if [[ $openVpnFlag == 0 ]]; then
        open -a $VPN_CLIENT_APP # open vpn app
        openVpnFlag=1
      fi
      echo '\033[1;31mNot connected to the VPN! Please connect using your VPN Client App! \033[0m'
      read confirm"?Connected now? (Y/N): "
      if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        publicIP=$(curl ifconfig.me)
      fi
    done
    echo "\033[1;32mUsing VPN \033[0m"
  fi
}

function load-dev-cli() {
  for dir in $(find $PROJECT_DIR -mindepth 1 -maxdepth 1 -type d); do
    if [[ "$PWD" == "$dir" ]]; then
      get-aws-ceredentials-expiration aws_expiration_date
      local aws_expiration_date_formated=$(date -d $aws_expiration_date +%s)
      local date_now_formated=$(date +%s)

      if [[ $aws_expiration_date_formated -lt $date_now_formated ]]; then
        check-vpn-connection
        saml2aws login
        dev-cli configure --code-artifact
      else
         print-c "AWS - credentials are not expired, skipping!"
      fi
    fi
  done
}


function use-npm-registry(){
  local npmrc_copy=~/.npmrc_copy
  local yarnrc_copy=~/.yarnrc_copy

  local npmrc=~/.npmrc
  local yarnrc=~/.yarnrc
  local yarnrcyml=~/.yarnrc.yml

  check-file-exists $npmrc && \
  { print-c "Removing .npmrc"; rm -rf $npmrc }
  print-c "Adding .npmrc with npm registry"
  cp $npmrc_copy $npmrc

  check-file-exists $yarnrc && \
  { print-c "Removing .yarnrc"; rm -rf $yarnrc }
  check-file-exists $yarnrcyml && \
  { print-c "Removing .yarnrc.yml"; rm -rf $yarnrcyml }

  print-c "Adding .yarnrc with yarnpkg registry"
  cp $yarnrc_copy $yarnrc

}
