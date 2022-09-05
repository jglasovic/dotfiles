#!/bin/sh

function is_vpn_connected(){
  local publicIP=`curl -s ifconfig.me/ip`
  [[ $MY_VPN_IP == $publicIP ]]
}

function vpn_check(){
  if is_vpn_connected; then
    echo "\033[1;32mUsing VPN! \033[0m"
  else
    print-red "Not connected to VPN!"
  fi
}

function vpn_connect(){
  if ! variable_exists $MY_VPN_IP; then
    echo "MY_VPN_IP required!"
    return 1
  fi

  if is_vpn_connected; then
    echo "VPN connected!"
    return 0
  fi

  if ! variable_exists $OVPN_CONFIG; then
    echo "OVPN_CONFIG required!"
    return 1
  fi

  sudo openvpn --config $OVPN_CONFIG &
}

function vpn_disconnect(){
  if is_app_running "openvpn"; then
   sudo killall openvpn
  fi
  return 0
}

function ensure_vpn_connected(){
  vpn_connect
  echo -ne "VPN Connecting ..."
  while ! is_vpn_connected ; do
    echo -ne "."
    sleep 1
  done
  echo "VPN Connected!"
  return 0
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


function load-dev-cli() {
  if ! variable_exists $PROJECT_DIR; then
    return 1
  fi

  for dir in $(find $PROJECT_DIR -mindepth 1 -maxdepth 1 -type d); do
    if [[ "$PWD" == "$dir" ]]; then
      get-aws-ceredentials-expiration aws_expiration_date
      if ! is_app_running docker ; then
        open -a docker
      fi
      local aws_expiration_date_formated=$(date -d $aws_expiration_date +%s)
      local date_now_formated=$(date +%s)

      if [[ $aws_expiration_date_formated -lt $date_now_formated ]]; then
        saml2aws login
        dev-cli configure --code-artifact

      else
         print-red "AWS - credentials are not expired, skipping!"
      fi
    fi
  done
}

# restoring default npm registry from backup files, dev-cli overwrites them
function npmrc-restore(){
  local npmrc_bak=~/.npmrc.bak
  local yarnrc_bak=~/.yarnrc.bak

  local npmrc=~/.npmrc
  local yarnrc=~/.yarnrc
  local yarnrcyml=~/.yarnrc.yml

  check-file-exists $npmrc && \
  { print-red "Removing .npmrc"; rm -rf $npmrc }
  print-red "Adding .npmrc with npm registry"
  cp $npmrc_bak $npmrc

  check-file-exists $yarnrc && \
  { print-red "Removing .yarnrc"; rm -rf $yarnrc }
  check-file-exists $yarnrcyml && \
  { print-red "Removing .yarnrc.yml"; rm -rf $yarnrcyml }

  print-red "Adding .yarnrc with yarnpkg registry"
  cp $yarnrc_bak $yarnrc
}
