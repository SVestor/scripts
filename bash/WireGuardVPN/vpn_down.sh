#!/bin/bash

# Author: SV
# Date Created: 07/21/24
# Last Modified: 07/21/24

# Description:  vpn down routing script
# Usage:
# vpn_down_script

# Delete INPUT 10.0.2.0/24 to 80/443
iptables -D INPUT -p tcp --dport 80 -s 10.0.2.0/24 -j ACCEPT
iptables -D INPUT -p tcp --dport 443 -s 10.0.2.0/24 -j ACCEPT

# Open INPUT from Global 0.0.0.0/0 to 80/443
iptables -D INPUT -p tcp --dport 80 -s 0.0.0.0/0 -j REJECT
iptables -D INPUT -p tcp --dport 443 -s 0.0.0.0/0 -j REJECT

# Delete Forward INPUT/OUTPUT to wg0
iptables -D FORWARD -i %i -j ACCEPT 
iptables -D FORWARD -o %i -j ACCEPT
iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# Check if finished with the code eq 0
err_code=$?

if [[ ${err_code} -eq 0 ]]; then
  echo "Completed Successfully $(date +%d-%m-%Y_%H-%M-%S)"
  exit 0
else
  echo "An error occurred: ${err_code}" 
  exit ${err_code}
fi
