#!/bin/bash

PCI_PATH="/sys/bus/pci/devices"
TBT_PATH="/sys/bus/thunderbolt/devices"
REGEX_ITEM="-"
HOST_EXCLUDE="\-0"
PCI_HEX_FILE="/tmp/PCI_HEX.txt"
PCI_DEC_FILE="/tmp/PCI_DEC.txt"
PCI_HEX=""
PCI_DEC=""

find_root_pci()
{
  local icl=$(dmidecode | grep "ICL")

  if [[ -n "$icl" ]]; then
     echo "ICL platform"
     tbt_dev=$(ls ${TBT_PATH} \
             | grep "$REGEX_ITEM" \
             | grep -v "$HOST_EXCLUDE" \
             | awk '{ print length(), $0 | "sort -n" }' \
             | grep ^3 \
             | cut -d ' ' -f 2 \
             | head -n1)

     case ${tbt_dev} in
       0-1)
         ROOT_PCI="0000:00:07.0"
         ;;
       0-3)
         ROOT_PCI="0000:00:07.1"
         ;;
       1-1)
         ROOT_PCI="0000:00:07.2"
         ;;
       1-3)
         ROOT_PCI="0000:00:07.3"
         ;;
       *)
         echo "ICL platform didn't find root pci, set 0000:00:07.0 as default!!!"
         ROOT_PCI="0000:00:07.0"
         ;;
     esac
  else
    ROOT_PCI=$(udevadm info --attribute-walk --path=/sys/bus/thunderbolt/devices/0-0 | grep KERNEL | tail -n 2 | grep -v pci0000 | cut -d "\"" -f 2)
    #ROOT_PCI="0000:03:00.0"
  fi
}

tbt_ds_pci()
{
  local pcis=""
  local pci=""
  local pci_ds=""
  local pci_content=""

  pcis=$(ls -1 $PCI_PATH)
  for pci in $pcis; do
    pci_ds=""
    pci_content=$(ls -ltra $PCI_PATH/$pci)
    pci_ds=$(lspci -v -s $pci | grep -i downstream)
    if [[ -z "$pci_ds" ]]; then
      continue
    else
      echo "Downstream pci:$pci"
    fi
  done
}

tbt_us_pci()
{
  local pcis=""
  local pci=""
  local pci_us=""
  local pci_content=""

  [[ -n "$ROOT_PCI" ]] || {
    echo "Could not find tbt root PCI, exit!"
    exit 2
  }
  pcis=$(ls -1 $PCI_PATH)
  cat /dev/null > $PCI_HEX_FILE
  cat /dev/null > $PCI_DEC_FILE
  for pci in $pcis; do
    pci_ds=""
    PCI_HEX=""
    PCI_DEC=""
    pci_content=$(ls -ltra $PCI_PATH/$pci)
    [[ "$pci_content" == *"$ROOT_PCI"* ]] || continue

    pci_us=$(lspci -v -s $pci | grep -i upstream)
    if [[ -z "$pci_us" ]]; then
      continue
    else
      echo "Upstream pci:$pci"
      PCI_HEX=$(echo $pci | cut -d ':' -f 2)
      PCI_DEC=$((0x"$PCI_HEX"))
      # Due to ICL tbt driver PCI 00:0d.2 and 00:0d.3
      # hard code to greater than 3: tbt driver pci
      [[ "$PCI_DEC" -gt 3 ]] || {
        echo "$PCI_DEC not greater than 3, skip"
        continue
      }
      echo $PCI_HEX >> $PCI_HEX_FILE
      echo $PCI_DEC >> $PCI_DEC_FILE
    fi
  done
  echo "TBT device upstream PCI in hex:"
  cat $PCI_HEX_FILE
  echo "TBT device upstream PCI in dec:"
  cat $PCI_DEC_FILE
}

find_root_pci
#tbt_ds_pci
tbt_us_pci
