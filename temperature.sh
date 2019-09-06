#!/bin/bash
file="/root/temperature.txt"

cat /dev/null > $file
for((i=1; i<=100000; i++)); do
  echo "i:$i"
  echo "i:$i" >> $file

  temp=$(cat /sys/class/thermal/thermal_zone0/temp)
  date=$(date +%Y-%m-%d_%H:%M:%S)
  echo "$date | temp:$temp"
  echo "$date | temp:$temp" >> $file
  sleep 5
done
