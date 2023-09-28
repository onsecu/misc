#!/bin/bash

# iptables binary

IPT="/sbin/iptables"

# IP Adressen / Accept
IP_ALLOW=("a.b.c.d","a.b.c.d")

# Dynamic IP address assignment
IPA=`dig +short -t a example.com | tail -1`
# Append to Array
IP_ALLOW+=($IPA)

# Alte Konfiguration löschen
$IPT -F
$IPT -X

# Default Policy
$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP

# Bestehende Verbindungen erlauben
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$IPT -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Loopback erlauben
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

# SSH / ICMP INPUT ### LOOP
for ip_ssh in "${IP_ALLOW[@]}"
do
        $IPT -A INPUT -m state --state NEW -p tcp --dport 22 -s $ip_ssh -j ACCEPT
done

# Open Ports
$IPT -A INPUT -m state --state NEW -p tcp --dport 443 -j ACCEPT
$IPT -A INPUT -m state --state NEW -p tcp --dport 80 -j ACCEPT

