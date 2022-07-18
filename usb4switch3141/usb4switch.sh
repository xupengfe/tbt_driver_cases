#!/bin/bash

serial_cmd() {
  local cmd_file=$1

  {
    sleep 1;
    while pgrep runscript > /dev/null; do
      sleep 1;
    done;
    cat escape.txt;
  } | minicom -b 9600 -D /dev/ttyACM0 -S $cmd_file -C capture.txt
}

check_status() {
  local state=""

  state=$(serial_cmd "status" | grep "PORTF" 2>/dev/null)
  if [[ -z "$state" ]]; then
    echo "Seems no USB4 switch 3141 connected state:$state"
  else
    echo "USB4 switch 3141 connected, state:$state"
  fi
}

plug_in() {
  local plug_state=""

  plug_state=$(serial_cmd "status" | grep "PORTF: 0x12" 2>/dev/null)
  if [[ -n "$plug_state" ]]; then
    echo "Already connected port 1 for USB4 switch:$plug_state"
  else
    echo "plug_state:$plug_state not 0x12 to connect port1."
    serial_cmd "superspeed"
    serial_cmd "port1"
  fi
}

plug_out() {
  local plug_state=""

  plug_state=$(serial_cmd "status" | grep "PORTF: 0x70" 2>/dev/null)
  if [[ -n "$plug_state" ]]; then
    echo "Already disconnected port 1 for USB4 switch:$plug_state"
  else
    echo "plug_state:$plug_state not 0x70 for all disconnected."
    serial_cmd "superspeed"
    serial_cmd "port0"
  fi
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

parm=$1
case $parm in
  s)
    check_status
    ;;
  on)
    plug_in
    ;;
  off)
    plug_out
    ;;
  *)
    hot_plug
    ;;
esac
