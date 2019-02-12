#!/bin/bash

ip=$1

tbt_net="tbt_net.txt"
tbt_net_last="tbt_net_last.txt"

[[ -e "$tbt_net" ]] && mv $tbt_net $tbt_net_last

[[ -n "$ip" ]] || {
	echo "Didn't set host ip, set host ip 192.168.1.11 by default"
	echo "Didn't set host ip, set host ip 192.168.1.11 by default" >  $tbt_net
	ip="192.168.1.11"
	}

echo "Linux kernel $(uname -r)" >> $tbt_net
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
