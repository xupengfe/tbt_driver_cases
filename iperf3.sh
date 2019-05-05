#!/bin/bash

ip=$1
ip_host="192.168.1.10"
local_guest_default="192.168.1.11"

tbt_net="tbt_net_$(date +%Y%m-%d_%H_%M).txt"


[[ -n "$ip" ]] || {
	echo "Didn't set host ip, need set local guest ip $local_guest_default by default"
	echo "Didn't set host ip, need set local guest ip $local_guest_default by default" > $tbt_net
	echo "Host ip should be $ip_host"
	ifconfig thunderbolt0 $local_guest_default
	echo "ifconfig thunderbolt0 $local_guest_default"
	echo "ifconfig thunderbolt0 $local_guest_default" >> $tbt_net
	ip=$ip_host
	}

echo "$(date +%m-%d_%H_%M): Linux kernel $(uname -r)" >> $tbt_net
echo "cmdline $(cat /proc/cmdline)" >> $tbt_net
echo "test tbt net at $(date +%Y-%m-%d\ %H:%M:%S)" >>  $tbt_net
echo "----------------------------------------------------------"


echo "iperf3 -c $ip"
echo "1. TEST iperf3 -c $ip" >> $tbt_net
iperf3 -c $ip >> $tbt_net

echo "iperf3 -c $ip -R"
echo "2. TEST iperf3 -c $ip -R" >> $tbt_net
iperf3 -c $ip -R >> $tbt_net

echo "iperf3 -M 101 -c $ip"
echo "3. TEST iperf3 -M 101 -c $ip" >> $tbt_net
iperf3 -M 101 -c $ip >> $tbt_net

echo "iperf3 -M 101 -c $ip -R"
echo "4. TEST iperf3 -M 101 -c $ip -R" >> $tbt_net
iperf3 -M 101 -c $ip -R >> $tbt_net

echo "iperf3 -u -c $ip"
echo "5. TEST iperf3 -u -c $ip" >> $tbt_net
iperf3 -u -c $ip -R >> $tbt_net


echo "iperf3 -u -c $ip -R"
echo "6. TEST iperf3 -u -c $ip -R" >> $tbt_net
iperf3 -u -c $ip -R >> $tbt_net

echo "iperf3 test finished, result was saved in $tbt_net"
