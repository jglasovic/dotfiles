#!/bin/sh

source $HOME/.zsh/utils.sh

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

# Requires VPN_CONFIG_PATH and MY_VPN_IP
function check_vpn_connection(){
  print-red $VPN_CLIENT_APP
  # I could do without vpn ip. could check about the running process
  print-red $MY_VPN_IP
  if ! variable_exists $VPN_CLIENT_APP  ||  ! variable_exists $MY_VPN_IP; then
    echo "VPN_CLIENT_APP and MY_VPN_IP are required!"
    return 1
  fi
  while ! is_vpn_connected ; do
    if ! is_app_running "$VPN_CLIENT_APP"; then
      open -a "$VPN_CLIENT_APP" # open vpn app
    fi
    echo '\033[1;31mNot connected to the VPN! Please connect using your VPN Client App! \033[0m'
    read confirm"?Connected now? (Y/N): "
    if [[ $confirm != [yY] || $confirm != [yY][eE][sS] ]]; then
      break
    fi
  done
  vpn_check
  return 0
}

