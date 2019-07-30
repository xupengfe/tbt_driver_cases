#!/bin/bash


tbt_device_check() {
  local pcis=$(lspci |  cut -d ' ' -f 1)
  local pci=""
  local is_tbt_pci=""
  local pci_device=""
  local tbt_device_num=0

  for pci in $pcis; do
    is_tbt_pci=""
    pci_device=""
    is_tbt_pci=$(lspci -vv -s "$pci"| grep "thunderbolt")
    if [[ -z "$is_tbt_pci" ]]; then
      continue
    else
      tbt_device_num=$((tbt_device_num + 1))
      pci_device=$(lspci | grep "$pci" | awk -F "Device" '{print $2}' | cut -d ' ' -f 2)
      echo "tbt pci:$pci  device_id:$pci_device"
      [[ -n "$pci_device" ]] || echo "tbt device id is null->$(lspci | grep "$pci")"
    fi
  done
  echo "tbt device num:$tbt_device_num"
}

tbt_device_check
