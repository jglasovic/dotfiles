#!/bin/sh

# function is_vpn_connected(){
#   local publicIP=`curl -s ifconfig.me/ip`
#   [[ $MY_VPN_IP == $publicIP ]]
# }

# function vpn_check(){
#   if is_vpn_connected; then
#     echo "\033[1;32mUsing VPN! \033[0m"
#   else
#     print-red "Not connected to VPN!"
#   fi
# }

# function vpn_connect(){
#   if ! variable_exists $MY_VPN_IP; then
#     echo "MY_VPN_IP required!"
#     return 1
#   fi

#   if is_vpn_connected; then
#     echo "VPN connected!"
#     return 0
#   fi

#   if ! variable_exists $OVPN_CONFIG; then
#     echo "OVPN_CONFIG required!"
#     return 1
#   fi

#   sudo openvpn $OVPN_CONFIG

# }
