#!/bin/bash
#https://wiki.strongswan.org/projects/strongswan/wiki/IKEv2CipherSuites#Diffie-Hellman-Groups
#https://www.cisco.com/c/en/us/support/docs/security/asa-5500-x-series-firewalls/215884-configure-a-site-to-site-vpn-tunnel-with.html
#https://www.cisco.com/c/en/us/support/docs/ip/internet-key-exchange-ike/117258-config-l2l.html
#           encryption-integrity-DiffiHellman Group
# 	ike=aes256-sha2_256-modp1024!

apt update -y  && sudo apt dist-upgrade -y
apt install strongswan -y

cat >> /etc/sysctl.conf << EOF
echo net.ipv4.ip_forward = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
EOF

sysctl -p /etc/sysctl.conf
openssl rand -base64 64


PSK=`openssl rand -base64 64`
cat >> /etc/ipsec.secrets << EOF
# source        destination
192.241.158.172 APS_Public IP : PSK "$PSK"
EOF

cat >> /etc/ipsec.conf << EOF

# basic configuration
# Our Digital Ocean Subnet: 10.116.0.2/20
config setup
        charondebug="all"
        uniqueids=yes
        strictcrlpolicy=no

# connection to APS site
conn ngtech-to-APS
	authby=secret
	left=%defaultroute
	leftid=192.241.158.172
	leftsubnet=10.116.0.2/32
	right=APS_Public
        rightid=APS_Public
	rightsubnet=APS_Private/24
	ike=aes256-sha2_256-modp1024!
	esp=aes256-sha2_256!
	keyingtries=0
	ikelifetime=1h
	lifetime=8h
	dpddelay=30
	dpdtimeout=120
	dpdaction=restart
	auto=start
	#keyexchange=ikev2
EOF

sudo iptables -t nat -A POSTROUTING -s APS_Private_Subnet/24 -d 10.116.0.2/32 -j MASQUERADE
sudo systemctl enable ipsec.service
sudo systemctl start ipsec.service
sudo systemctl status ipsec.service

#sudo ipsec up ngtech-to-APS
#sudo ipsec down ngtech-to-APS

#sudo ipsec restart
#sudo ipsec status
#sudo ipsec statusall
# Get the Policies and States of the IPsec Tunnel:
#sudo ip xfrm state
#sudo ip xfrm policy


