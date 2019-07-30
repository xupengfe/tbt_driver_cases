#!/bin/bash


tbt_device_check() {
  local pcis=$(lspci |  cut -d ' ' -f 1)
  local pci=""
  local is_tbt_pci=""
  local pci_device=""

  for pci in $pcis; do
    is_tbt_pci=""
    pci_device=""
    is_tbt_pci=$(lspci -vv -s "$pci"| grep "thunderbolt")
    if [[ -z "$is_tbt_pci" ]]; then
      continue
    else
      pci_device=$(lspci | grep "$pci" | awk -F "Device" '{print $2}' | cut -d ' ' -f 2)
      echo "tbt pci:$pci  device_id:$pci_device"
      [[ -n "$pci_device" ]] || echo "tbt device id is null->$(lspci | grep "$pci")"
    fi
  done
}

tbt_device_check
