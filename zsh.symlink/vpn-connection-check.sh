#!/bin/sh

source $HOME/.zsh/utils.sh

# VPN check connection
# requires VPN_CLIENT_APP and MY_VPN_IP
function check-vpn-connection(){
  print-red $VPN_CLIENT_APP
  print-red $MY_VPN_IP
  if ! variable_exists $VPN_CLIENT_APP  ||  ! variable_exists $MY_VPN_IP; then
    echo "VPN_CLIENT_APP and MY_VPN_IP are required!"
  else
    local openVpnFlag=0
    local publicIP=`curl ifconfig.me/ip`

    while [[ $MY_VPN_IP != $publicIP ]]; do
      if [[ $openVpnFlag == 0 ]]; then
        open -a $VPN_CLIENT_APP # open vpn app
        openVpnFlag=1
      fi
      echo '\033[1;31mNot connected to the VPN! Please connect using your VPN Client App! \033[0m'
      read confirm"?Connected now? (Y/N): "
      if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        publicIP=`curl ifconfi.me/ip`
      fi
    done
    echo "\033[1;32mUsing VPN \033[0m"
  fi
}
