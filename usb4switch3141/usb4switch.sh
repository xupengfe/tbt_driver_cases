#!/bin/bash

SWITCH_NODE="/dev/ttyACM0"

# Any path could run this script
cd "$(dirname $0)" 2> /dev/null

usage() {
  cat <<__EOF
  usage: ./${0##*/}  [1|2|0 or off|s|h|*]
  1    Connect host port to port 1 with super speed
  2    Connect host port to port 2 with super speed
  0|off  Disconned all ports with host port
  s    Check current status
  hot  One round port 1, 2 and disconnect test
  h|*  Show this and show status
__EOF
}

serial_cmd() {
  local cmd_file=$1

  {
    sleep 1
    cat escape.txt
  } | minicom -b 9600 -D "$SWITCH_NODE" -S $cmd_file -C capture.txt
}

check_status() {
  local state=""
  local port=""

  state=$(serial_cmd "status" | grep "PORTF" 2>/dev/null)
  port=$(echo "$state" | awk -F ' ' '{print $NF}')
  if [[ -z "$state" ]]; then
    echo "Didn't detect USB4 switch 3141 state:$state"
    return 1
  else
    echo "Detected USB4 switch 3141, state:$state"
  fi
  if [[ $port == *"0x12"* ]]; then
    echo "Connect with port 1"
  elif  [[ $port == *"0x3"* ]]; then
    echo "Connect with port 2"
  else
    echo "No ports connected."
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

plug_in2() {
  local plug_state=""

  plug_state=$(serial_cmd "status" | grep "PORTF: 0x3" 2>/dev/null)
  if [[ -n "$plug_state" ]]; then
    echo "Already connected port 2 for USB4 switch:$plug_state"
  else
    echo "plug_state:$plug_state not 0x3 to connect port1."
    serial_cmd "superspeed"
    serial_cmd "port2"
  fi
}

plug_out() {
  local plug_state=""

  plug_state=$(serial_cmd "status" | grep "PORTF: 0x70" 2>/dev/null)
  if [[ -n "$plug_state" ]]; then
    echo "Already disconnected port 1 & 2 for USB4 switch:$plug_state"
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
[[ -e "$SWITCH_NODE" ]] || {
  echo "SKIP: No USB4 switch node:$SWITCH_NODE"
  usage
  exit 2
}

case $parm in
  s)
    check_status
    ;;
  1)
    plug_in
    ;;
  2)
    plug_in2
    ;;
  0|off)
    plug_out
    ;;
  hot)
    hot_plug
    ;;
  *)
    usage
    check_status
    ;;
esac
