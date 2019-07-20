#!/bin/bash

#cat  read_*.CSV
#cat  write_*.CSV
eth_ports=$(nmcli device | grep ethernet | awk '{print $1}' | xargs)
echo "eth_ports: $eth_ports"

for eth in "$eth_ports"; do
  echo "sudo ifconfig $eth up"
  sudo ifconfig $eth up
done
#eval "t=($(nmcli device | grep ethernet | awk '{print $1}' | xargs))"; for i in ${t[@]}; do sudo ifconfig $i up; done;
