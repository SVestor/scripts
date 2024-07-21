#!/bin/bash

# Author: SV
# Date Created: 07/21/24
# Last Modified: 07/21/24

# Description:  vpn up routing script
# Usage:
# vpn_up_script

# Allow INPUT 10.0.2.0/24 to 80/443
iptables -A INPUT -p tcp --dport 80 -s 10.0.2.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -s 10.0.2.0/24 -j ACCEPT

# Drop INPUT Global 0.0.0.0/0 to 80/443
iptables -A INPUT -p tcp --dport 80 -s 0.0.0.0/0 -j REJECT
iptables -A INPUT -p tcp --dport 443 -s 0.0.0.0/0 -j REJECT

# Forward INPUT/OUTPUT to wg0
iptables -A FORWARD -i %i -j ACCEPT 
iptables -A FORWARD -o %i -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Check if finished with the code eq 0
err_code=$?

if [[ ${err_code} -eq 0 ]]; then
  echo "Completed Successfully $(date +%d-%m-%Y_%H-%M-%S)"
  exit 0
else
  echo "An error occurred: ${err_code}" 
  exit ${err_code}
fi
