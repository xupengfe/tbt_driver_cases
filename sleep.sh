#!/bin/bash

i=1
n=5
sleep_log="/root/test_sleep.log"
dmesg_file="/root/dmesg.log"

[[ -e "$dmesg_file" ]] && {
	  mv $dmesg_file /root/dmesg_bak.log
          echo "mv $dmesg_file /root/dmesg_bak.log" 
          echo "mv $dmesg_file /root/dmesg_bak.log" >> $sleep_log
	}
echo "echo deep > /sys/power/mem_sleep"
echo "echo deep > /sys/power/mem_sleep" > $sleep_log
echo deep > /sys/power/mem_sleep

for ((i = 1; i <= n; i++)); do
	echo "****$i times ****: rtcwake -m mem -s 20"
	echo "****$i times ****: rtcwake -m mem -s 20" >> $sleep_log
	rtcwake -m mem -s 20
	[[ "$?" -eq 0 ]] || {
	echo "$i times s3 sleep failed return not 0!"
	echo "$i times s3 sleep failed return not 0!" >> $sleep_log
	echo "dmesg > $dmesg_file"
	dmesg > $dmesg_file
	exit 1
	}
	echo "sleep 10"
	echo "sleep 10" >> $sleep_log
	sleep 10
done
	echo "sleep test OK!" >> $sleep_log
	echo "dmesg > $dmesg_file"
	dmesg > $dmesg_file
