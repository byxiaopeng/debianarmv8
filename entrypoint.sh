#!/bin/bash
# 开启转发
sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g" /etc/sysctl.conf
sysctl -p
#重置iptables
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X

#tcp-udp
ip rule add fwmark 1 table 100
ip route add local default dev lo table 100
iptables -t mangle -N clash
iptables -t mangle -A clash -d 0.0.0.0/8 -j RETURN
iptables -t mangle -A clash -d 10.0.0.0/8 -j RETURN
iptables -t mangle -A clash -d 127.0.0.0/8 -j RETURN
iptables -t mangle -A clash -d 169.254.0.0/16 -j RETURN
iptables -t mangle -A clash -d 172.16.0.0/12 -j RETURN
iptables -t mangle -A clash -d 192.168.0.0/16 -j RETURN
iptables -t mangle -A clash -d 224.0.0.0/4 -j RETURN
iptables -t mangle -A clash -d 240.0.0.0/4 -j RETURN
iptables -t mangle -A clash -p tcp -j TPROXY --on-port 7893 --tproxy-mark 1
iptables -t mangle -A clash -p udp -j TPROXY --on-port 7893 --tproxy-mark 1

iptables -t mangle -A PREROUTING -j clash
#DNS
iptables -t nat -N CLASH_DNS
iptables -t nat -F CLASH_DNS 
iptables -t nat -A CLASH_DNS -p udp -j REDIRECT --to-port 1053
iptables -t nat -I OUTPUT -p udp --dport 53 -j CLASH_DNS
iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to 1053
#启动SSH
/usr/sbin/sshd
#启动AdGuardHome
AdGuardHome -c /AdGuardHome/AdGuardHome.yaml >/dev/null 2>&1 &
#启动 clash
clash
