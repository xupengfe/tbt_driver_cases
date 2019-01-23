#! /bin/bash
#
# Copyright 2017 Intel Corporation
#
# This file is part of LTP-DDT for IA to validate thunderbolt component
#
# This program file is free software; you can redistribute it and/or modify it
# under the terms and conditions of the GNU General Public License,
# version 1, as published by the Free Software Foundation.
#
# This program is distributed in the hope it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# Author:
#             Pengfei Xu <pengfei.xu@intel.com>
#
# History:
#             April. 18, 2017


# @desc This script verify controllers files exist on sysfs for thunderbolt
# @params None
# @returns Fail the test if return code is non-zero (value set not found)

#source "common.sh"  # Import do_cmd(), die() and other functions
############################# Functions ########################################
TIME_FMT="%Y%m%d-%H%M%S.%N"
CHECK_TIME=0
ROOT_PCI=""
TBT_PATH="/sys/bus/thunderbolt/devices"
REGEX_ITEM="-"
HOST_EXCLUDE="\-0"

usage()
{
        cat <<-EOF >&2
        usage: ./${0##*/} [-h help] Or no need parameter
EOF
        exit 0
}

test_print_trc()
{
  log_info=$1      # trace information
  echo "|$(date +"$TIME_FMT")|TRACE|$log_info|"
  echo "|$(date +"$TIME_FMT")|TRACE|$log_info|" >> /root/test_tbt_1.log
}



################################ CLI Params ####################################
# Please use getopts
while getopts  :h arg
do case $arg in
                h)      usage;;
                :)      usage
                        exit 0
                        ;;
                \?)     usage
                        exit 0
                        ;;
esac
done




############################ Default Values for Params##########################
########################### REUSABLE TEST LOGIC ################################
PCI_PATH="/sys/bus/pci/devices"

rm -rf /root/test_tbt_1.log

parm=$1

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
         echo "ICL platform didn't find root pci!!!"
         ;;
     esac
  else
    ROOT_PCI="0000:03:00.0"
  fi
}

pci_main()
{
  local par="$1"
  local tbt="non-tbt"
  local dev_path="/sys/bus/pci/devices"
  local rstate=""
  local icl=$(dmidecode | grep "ICL")
  
  find_root_pci
  if [[ -z "$ROOT_PCI" ]]; then
    if [[ "$CHECK_TIME" -eq 0 ]]; then
      CHECK_TIME=1
      ./cleware 1
      sleep 30
      find_root_pci
      sleep 5
      ./cleware 0
    else
      echo "ICL could not find PCI 2nd time!!"
      exit 1
   fi
  fi

  rstate=$(cat $dev_path/$ROOT_PCI/power/runtime_status)
  #rstate=$(lspci -vv -s 03:00 2> /dev/null | grep Status | grep "PME-" | cut -d ' ' -f 2)
  echo "$ROOT_PCI runtime_status:$rstate"
  if [[ -z "$icl" ]]; then
    local ROOT_PCI=$(udevadm info --attribute-walk --path=/sys/bus/thunderbolt/devices/0-0 | grep KERNEL | tail -n 2 | grep -v pci0000 | cut -d "\"" -f 2)
  else
    [[ -z "$ROOT_PCI" ]] && echo "Error! ICL didn't find root pci:$ROOT_PCI"
  fi
  local pci_info=""
  local pci_log="/tmp/tbt_pci.txt"

  cat "/dev/null" > $pci_log
  echo "tbt_ROOT_PCI: $ROOT_PCI"
  PCI_LIST=$(ls $PCI_PATH)
  echo "Path:$PCI_PATH/XXX_PCI_BUS/power/"
  rstate=""
  rstate=$(cat /sys/bus/pci/devices/$ROOT_PCI/power/runtime_status)
  #rstate=$(lspci -vv -s 03:00 2> /dev/null | grep Status | grep "PME-" | cut -d ' ' -f 2)
  local root_real_status=""
  local root_run_status=""
  local root_control=""
  local root_type=""
  local acl_file="/sys/bus/thunderbolt/devices/domain0/boot_acl"
  local power_control="/sys/bus/thunderbolt/devices/0-0/power/control"

  echo "$ROOT_PCI runtime_status:$rstate"
  if [[ -e "$acl_file" ]]; then
    echo "cat $acl_file"
    cat $acl_file
  else
    echo "set on in $power_control"
    echo "on" > $power_control
    echo "set auto in $power_control"
    echo "auto" > $power_control
  fi
  echo "sleep 25"
  sleep 25


  root_real_status=$(cat $PCI_PATH/$ROOT_PCI/firmware_node/power_state 2>/dev/null)
  root_run_status=$(cat $PCI_PATH/$ROOT_PCI/power/runtime_status)
  root_control=$(cat $PCI_PATH/$ROOT_PCI/power/control)
  root_type=$(lspci -v -s $ROOT_PCI 2> /dev/null | grep "Kernel driver in use:" | awk -F "in use: " '{print $2}')


  for PCI in ${PCI_LIST}
    do
      tbt="non-tbt"
      run_status=""
      real_status=""
      if [[ "$PCI" == "$ROOT_PCI" ]]; then
        real_status="$root_real_status"
	run_status="$root_run_status"
        pci_control="$root_control"
	pci_type="$root_type"
      else
        control=$(cat $PCI_PATH/$PCI/power/control)
        run_status=$(cat $PCI_PATH/$PCI/power/runtime_status)
        pci_type=$(lspci -v -s $PCI 2> /dev/null | grep "Kernel driver in use:" | awk -F "in use: " '{print $2}')

        # comment line, due to if D3 cold, could not get the correct status. so use $PCI_PATH/XXX_PCI_BUS/power/firmware_node/power_state
        real_status=$(cat $PCI_PATH/$PCI/firmware_node/power_state 2>/dev/null)
        [[ -z "$real_status" ]] && real_status=$(lspci -vv -s $PCI 2> /dev/null | grep Status | grep "PME-" | cut -d ' ' -f 2)
      fi
      pci_content=$(ls -ltra $PCI_PATH/$PCI)
      #Check pci which contain ROOT_PCI pci, if yes it means it's tbt branch pci
      if [[ -n "$ROOT_PCI" ]]; then
        #echo "pci_content:$pci_content pci:$PCI"
	[[ "$pci_content" == *"$ROOT_PCI"* ]] && tbt="tbt"
        [[ "$PCI" == "$ROOT_PCI" ]] && tbt="tbt_root"
     fi

     if [[ $par == "tbt" ]]; then
       [[ "$tbt" == "non-tbt" ]] && continue
     fi

     [[ -z "$pci_type" ]] && pci_type="NA"
     [[ -z "$control" ]] && control="NA"
     [[ -z "$run_status" ]] && run_status="NA"
     [[ -z "$real_status" ]] && real_status="NA"

#     printf "$PCI->%-8s type:%-18s  control:%-12s runtime_status:%-12s real_status:%-12s\n" \
#	     "$tbt" "$pci_type" "$control" "$run_status" "$real_status"
     pci_info=$(printf "$PCI->%-8s type:%-18s  control:%-12s runtime_status:%-12s real_status:%-12s\n" \
		"$tbt" "$pci_type" "$control" "$run_status" "$real_status")
     echo "$pci_info" >> $pci_log 

     if [[ -n "$ROOT_PCI" ]]; then
       [[ "$PCI" == "$ROOT_PCI" ]] && echo "auto" > $PCI_PATH/$PCI/power/control
     fi
     if [[ "$control" == "on" ]]; then
       [[ "$tbt" == "tbt" ]] && {
         [[ "$pci_type" == *"hci"* ]] && echo "auto" > $PCI_PATH/$PCI/power/control
       }
	 #[[ "$pci_type" == "thunderbolt" ]] && echo "auto" > $PCI_PATH/$PCI/power/control
     fi
  done
  cat $pci_log
  echo "Before, root_real_status:$root_real_status"
  root_real_status=$(cat $PCI_PATH/$ROOT_PCI/firmware_node/power_state 2>/dev/null)
  echo "cat $PCI_PATH/$ROOT_PCI/firmware_node/power_state "
  echo "Current, root pci real status:$root_real_status"

}

pci_main "$parm"
