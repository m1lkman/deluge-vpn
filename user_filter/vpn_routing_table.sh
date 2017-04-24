#!/usr/bin/env bash
SRC_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SRC_DIR" ]]; then SRC_DIR="$PWD"; fi
source "$SRC_DIR/vpn_base.sh"

VPN_IP=$ifconfig_local

# Remove old table
ip route flush table $TABLE_ID

# Add rule to use TABLE_ID for marked packets
if [[ `ip rule list | grep -c $MARK_ID` == 0 ]]; then
	ip rule add from all fwmark $MARK_ID lookup $TABLE_ID
fi

ip route replace default via $VPN_IP table $TABLE_ID
ip route append default via 127.0.0.1 dev lo table $TABLE_ID
ip route flush cache

# Set reverse path source validation to lose mode
sysctl -w net.ipv4.conf.all.rp_filter=2
sysctl -w net.ipv4.conf.default.rp_filter=2
sysctl -w net.ipv4.conf.$VPNIF.rp_filter=2
