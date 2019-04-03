#!/bin/bash

BIOS_USB_NODE=""


find_usb() {
  nodes=$(lsblk | grep ^sd | cut -d ' ' -f 1)
  node=""
  bios_data="/bios_data"
  key_file="/bios_data/startup.nsh"

  [[ -n "$nodes" ]] || {
    echo "could not find BIOS USB"
    exit 2
  }

  [[ -d "$bios_data" ]] || {
    echo "$bios_data was not exist, create it"
    mkdir $bios_data
  }

  for node in ${nodes}; do
    mount /dev/${node} $bios_data
    if [[ $? -eq 0 ]]; then
      if [[ -e "$key_file" ]]; then
        echo "found $key_file in $node"
	BIOS_USB_NODE=$node
	break
      else
	echo "$node didn't contain $key_file"
	umount $bios_data
	continue
      fi
    else
        echo "mount $node failed, continue"
	continue
    fi
  done
}

find_usb
