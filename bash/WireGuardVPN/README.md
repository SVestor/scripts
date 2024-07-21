## A simple script for configuring firewall rules depending on the VPN server's state

### Task
It is necessary to have access to the same web server from both a private (WireGuard VPN) network and the global Internet. 
There should be the ability to switch btw incoming traffic without updating DNS. 
ex. When the VPN is enabled, the traffic should go only through the VPN , and vice versa the VPN is disabled, the traffic should go through the global Internet.

### Getting Started

- vpn server wg0.config:
```bash
[Interface]
Address =  10.0.2.1/24
ListenPort = 51820
PrivateKey = SERVER_PRIVATE_KEY

# substitute eth0 in the following lines to match the Internet-facing interface
# the FORWARD rules will always be needed since traffic needs to be forwarded between the WireGuard
# interface and the other interfaces on the server.
# if the server is behind a router and receives traffic via NAT, specify static routing back to the
# 10.200.200.0/24 subnet, the NAT iptables rules are not needed but the FORWARD rules are needed.
# if the server is behind a router and receives traffic via NAT but one cannot specify static routing back to
# 10.200.200.0/24 subnet, both the NAT and FORWARD iptables rules are needed. 

PostUp = /path/to/vpn_up.sh
PostDown = /path/to/vpn_up.sh

[Peer]
# foo
PublicKey = PEER_FOO_PUBLIC_KEY
PresharedKey = PRE-SHARED_KEY
AllowedIPs =  10.0.2.100/24

```
- /path/to/vpn_up.sh:
```bash
#!/bin/bash

# Author: SV
# Date Created: 07/21/24
# Last Modified: 07/21/24

# Description: vpn up routing script
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
```
- /path/to/vpn_down.sh:
```bash
#!/bin/bash

# Author: RM
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

```
### Add permissions to make script executable
```bash
chmod +x /path/to/vpn_up.sh
chmod +x /path/to/vpn_down.sh

sudo iptables -L -vn
sudo iptables -L INPUT -vn
sudo iptables -L FORWARD -vn
sudo iptables -L OUTPUT -vn

```
#### Getting help links 
**If you require more advanced documentation in relation to the topic**
- [IptablesHowTo](https://help.ubuntu.com/community/IptablesHowTo)
- [WireGuardConfiguration](https://wiki.archlinux.org/title/WireGuard#Server_configuration)
