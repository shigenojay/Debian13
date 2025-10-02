#!/bin/bash

#Looking For Desired IP Address
MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0'`;

#Installing Pre Packages
sudo apt-get update -y

# Install OPENVPN
sudo apt-get install openvpn -y
wait
apt-get install unzip
wait
wget https://github.com/shigenojay/Debian13/raw/refs/heads/main/shigeno.zip
unzip artkeys.zip
wait
cd

# menu
wget -O /usr/local/bin/menu "https://raw.githubusercontent.com/shigenojay/Debian13/refs/heads/main/shigenomenu.sh" chmod +x /usr/local/bin/menu

# Creating OpenVPN Config
cat > /root/client.ovpn <<-END
client
dev tun
proto tcp
remote $MYIP 443
resolv-retry infinite
redirect-gateway def1
nobind
sndbuf 393216
rcvbuf 393216
tun-mtu 1470
mssfix 1430
auth-user-pass
comp-lzo
http-proxy $MYIP 8080
http-proxy-retry
http-proxy-timeout 5
http-proxy-option CUSTOM-HEADER Host m.youtube.com
http-proxy-option CUSTOM-HEADER X-Online-Host m.youtube.com
route $MYIP 255.255.255.255 vpn_gateway
keepalive 10 120 
reneg-sec 432000
verb 3
script-security 3
setenv CLIENT_CERT 0

END
echo '<ca>' >> /root/client.ovpn
cat /etc/openvpn/keys/ca.crt >> /root/client.ovpn
echo '</ca>' >> /root/client.ovpn
cd

#Enable net.ipv4.ip_forward for the system
sed -i '/\<net.ipv4.ip_forward\>/c\net.ipv4.ip_forward=1' /etc/sysctl.conf
wait
if ! grep -q "\<net.ipv4.ip_forward\>" /etc/sysctl.conf; then
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
fi

# Renewing IP Tables
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
sudo iptables -L

# Disabling IPV6
IPT6="/sbin/ip6tables"
echo "Stopping IPv6 firewall..."
$IPT6 -F
$IPT6 -X
$IPT6 -Z
for table in $(</proc/net/ip6_tables_names)
do
        $IPT6 -t $table -F
        $IPT6 -t $table -X
        $IPT6 -t $table -Z
done
$IPT6 -P INPUT ACCEPT
$IPT6 -P OUTPUT ACCEPT
$IPT6 -P FORWARD ACCEPT
# Avoid an unneeded reboot
echo "1" > /proc/sys/net/ipv4/ip_forward
echo "1" > /proc/sys/net/ipv4/ip_dynaddr
iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
iptables -I FORWARD -i eth0 -o tun0 -j ACCEPT
iptables -I FORWARD -i tun0 -o eth0 -j ACCEPT
iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to $MYIP
iptables-save > /etc/iptables_pisovpn.conf
cd /etc/openvpn
mv iptables /etc/network/if-up.d/
cd
chmod +x /etc/network/if-up.d/iptables

# Setting up Squid Config
apt-get install squid -y
wait
echo '' > /etc/squid/squid.conf
wait
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
acl vpnservers dst $MYIP
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

# setting permission
cd
chmod 777 /etc/openvpn
chmod -R 755 /etc/openvpn

# restarting ovpn and squid
sudo systemctl start openvpn@server
systemctl enable openvpn@server
/etc/init.d/openvpn restart
service squid start
/lib/systemd/systemd-sysv-install enable squid
/etc/init.d/squid restart

# finilazing
rm *.sh *.zip
wait
rm -rf config
wait
rm -rf ~/.bash_history && history -c & history -w
echo ""
echo ""
echo "OpenVPN & Squid Proxy Successfully Installed"
echo ""
exit
