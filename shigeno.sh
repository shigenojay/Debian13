#!/bin/bash
# Private Script

# Color
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# update package
apt-get update;

# install openvpn, unzip & curl
apt-get install openvpn unzip build-essential curl dos2unix -y;

# generate dh parameters
openssl dhparam -out /etc/openvpn/dh2048.pem 2048;

# setting up iptables
iptables -t nat -A POSTROUTING -s 10.8.0.0/16 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.8.0.0/16 -o venet0 -j SNAT --to-source `curl ipecho.net/plain`

# download cert openvpn config
wget https://github.com/shigenojay/Debian13/raw/refs/heads/main/shigeno.zip -O shigeno.zip
unzip shigeno.zip
rm zip*
cp -r config/* /etc/openvpn
cd /root
chmod -R 755 /etc/openvpn

# Creating OpenVPN Config
cat > /root/client.ovpn <<-END
client
dev tun
proto tcp
remote `curl ipecho.net/plain` 443
resolv-retry infinite
redirect-gateway def1
nobind
sndbuf 393216
rcvbuf 393216
tun-mtu 1470
mssfix 1430
auth-user-pass
comp-lzo
http-proxy `curl ipecho.net/plain` 8080
http-proxy-retry
http-proxy-timeout 5
http-proxy-option CUSTOM-HEADER Host m.youtube.com
http-proxy-option CUSTOM-HEADER X-Online-Host m.youtube.com
route `curl ipecho.net/plain` 255.255.255.255 vpn_gateway
keepalive 10 120 
reneg-sec 432000
verb 3
script-security 3
setenv CLIENT_CERT 0

END
echo '<ca>' >> /root/client.ovpn
cat /etc/openvpn/ca.crt >> /root/client.ovpn
echo '</ca>' >> /root/client.ovpn
cd

# enable net.ipv4.ip_forward
echo 1 > /proc/sys/net/ipv4/ip_forward

# Setting up Squid Config
apt-get install squid3 -y
echo '' > /etc/squid/squid.conf
echo "acl localnet src 10.8.0.0/24	# RFC1918 possible internal network
acl localnet src 172.16.0.0/12	# RFC1918 possible internal network
acl localnet src 192.168.0.0/16	# RFC1918 possible internal network
acl localnet src fc00::/7       # RFC 4193 local private network range
acl localnet src fe80::/10      # RFC 4291 link-local (directly plugged) machines
acl SSL_ports port 443
acl SSL_ports port 992
acl SSL_ports port 995
acl SSL_ports port 5555
acl SSL_ports port 80
acl Safe_ports port 80		# http
acl Safe_ports port 21		# ftp
acl Safe_ports port 443		# https
acl Safe_ports port 70		# gopher
acl Safe_ports port 210		# wais
acl Safe_ports port 1025-65535	# unregistered ports
acl Safe_ports port 280		# http-mgmt
acl Safe_ports port 488		# gss-http
acl Safe_ports port 591		# filemaker
acl Safe_ports port 777		# multiling http
acl Safe_ports port 992		# mail
acl Safe_ports port 995		# mail
acl CONNECT method CONNECT
acl vpnservers dst `curl ipecho.net/plain`
acl vpnservers dst 127.0.0.1
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow localhost manager
http_access allow localnet
http_access allow localhost
http_access allow vpnservers
http_access deny !vpnservers
http_access deny manager
http_access allow all
http_port 0.0.0.0:8080
http_port 0.0.0.0:8989
http_port 0.0.0.0:3128
http_port 0.0.0.0:8000"| sudo tee /etc/squid/squid.conf

# menu
wget -O /usr/local/bin/menu "https://raw.githubusercontent.com/shigenojay/Debian13/refs/heads/main/shigenomenu.sh"
chmod +x /usr/local/bin/menu
apt-get -y install vnstat
apt install speedtest-cli

# restarting ovpn and squid
sudo systemctl start openvpn@server
systemctl enable openvpn@server
/etc/init.d/openvpn restart
service squid start
/lib/systemd/systemd-sysv-install enable squid
/etc/init.d/squid restart

# finilazing
rm *.sh *.zip
rm -rf config
rm -rf ~/.bash_history && history -c & history -w
	clear
	echo ""
	echo ""
	echo -e "${GREEN}Private Script By :${NC}"
	echo "    _         _   _  __ _      _       _  "
    echo "   / \   _ __| |_(_)/ _(_) ___(_) __ _| | "
    echo "  / _ \ | '__| __| | |_| |/ __| |/ _` | | "
    echo " / ___ \| |  | |_| |  _| | (__| | (_| | | "
    echo "/_/   \_\_|   \__|_|_| |_|\___|_|\__,_|_| "
    echo ""
	echo ""
	echo -e "${GREEN}OpenVPN & Squid Proxy Successfully Installed!${NC}"
	echo ""
	echo ""
	echo "Server IP : `curl ipecho.net/plain`"
	echo "OpenVPN Port : 443"
	echo "Squid Port : 3128, 8080, 8000, 8989"
	echo ""
	echo -e "OpenVPN Client Config Location @ ${CYAN}/root/client.ovpn${NC}"
	echo ""
	echo -e "Type ${CYAN}menu${NC} To See Command Lists."
	echo ""
	echo ""
	exit

