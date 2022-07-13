#!/bin/bash

serial_cmd() {
  local cmd_file=$1

  {
    sleep 2;
    while pgrep runscript > /dev/null; do
      sleep 2;
    done;
    cat escape.txt;
  } | minicom -b 9600 -D /dev/ttyACM0 -S $cmd_file -C capture.txt
}


hot_plug() {
  local p0=""
  local p1=""
  local p2=""

  serial_cmd "port0"
  p0=$(serial_cmd "status" | grep "PORTF")
  echo "p0:$p0"
  serial_cmd "superspeed"
  serial_cmd "port1"
  p1=$(serial_cmd "status" | grep "PORTF")
  echo "p1:$p1"
  serial_cmd "superspeed"
  serial_cmd "port2"
  p2=$(serial_cmd "status" | grep "PORTF")
  echo "p2:$p2"
  serial_cmd "superspeed"
  serial_cmd "port0"

  echo "p0:$p0"
  echo "p1:$p1"
  echo "p2:$p2"
}

hot_plug
