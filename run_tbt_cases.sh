#!/bin/bash

BIOS_USB_NODE=""
LINUX_VER=$(uname -r)
DATE=$(date +%m-%d_%H_%M)
LOG_PATH="/opt/logs/TBT_LOG"
TBT_LOG="/opt/logs/TBT_${LINUX_VER}_${DATE}"
BIOS_DATA="/bios_data"
DATE_FILE="${BIOS_DATA}/date"
PF=$1

find_usb() {
  nodes=$(lsblk | grep ^sd | cut -d ' ' -f 1)
  node=""
  key_file="/bios_data/startup.nsh"

  [[ -n "$nodes" ]] || {
    echo "could not find any node"
    exit 2
  }

  [[ -d "$BIOS_DATA" ]] || {
    echo "$BIOS_DATA was not exist, create it"
    mkdir $BIOS_DATA
  }

  umount $BIOS_DATA

  for node in ${nodes}; do
    echo "Check $node:"
    mount /dev/${node} $BIOS_DATA
    if [[ $? -eq 0 ]]; then
      if [[ -e "$key_file" ]]; then
        echo "found $key_file in $node"
	BIOS_USB_NODE=$node
        ls -ltrha $key_file
	break
      else
	echo "$node didn't contain $key_file"
	umount $BIOS_DATA
	continue
      fi
    else
        echo "mount $node failed, continue"
	continue
    fi
  done
  if [[ -z "$BIOS_USB_NODE" ]]; then
    echo "No $key_file in nodes, exit"
    exit 1
  fi
}

test_tbt() {
  tbt_done_file=""
  ddt_path=$(ls -1 /home/ltp-ddt_* | grep ^/home | tail -n 1 | cut -d ':' -f 1)
  run_tbt_file="${LOG_PATH}/run_tbt.log"
  all_set_txt="${BIOS_DATA}/*set*.txt"
  origin_date=$(cat $DATE_FILE)

  if [[ -z "$origin_date" ]]; then
    TBT_LOG="/opt/logs/TBT_${LINUX_VER}_${DATE}"
  else
    TBT_LOG="/opt/logs/TBT_${LINUX_VER}_${origin_date}"
  fi

  [[ -d "$LOG_PATH" ]] || {
    echo "No folder $LOG_PATH exist, create it"
    mkdir -p $LOG_PATH
  }

  [[ -z "$PF" ]] && PF="cfl-h-rvp"
  cd $BIOS_DATA
  tbt_done_file=$(ls -1 *set_done.txt)
  echo >> $run_tbt_file
  echo "**********************************" >> $run_tbt_file
  echo "$DATE, ddt path:$ddt_path" >> $run_tbt_file

  case ${tbt_done_file} in
    none_set_done.txt)
      cd $ddt_path
      echo "none mode test" >> $run_tbt_file
      echo "./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_none_tests,ddt_intel/tbt_func_tests -o $TBT_LOG -c" >> $run_tbt_file
      ./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_none_tests,ddt_intel/tbt_func_tests -o $TBT_LOG -c
      rm -rf $all_set_txt
      echo "$(date +%m-%d_%H_%M): delete *set*.txt, set user_set.txt in $BIOS_DATA" >> $run_tbt_file
      echo "next" > $BIOS_DATA/user_set.txt
      ls $BIOS_DATA
      echo "$(ls $BIOS_DATA)" >> $run_tbt_file
      reboot
      ;;
    user_set_done.txt)
      cd $ddt_path
      echo "user mode test" >> $run_tbt_file
      echo "./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_user_tests,ddt_intel/tbt_func_tests -o $TBT_LOG -c" >> $run_tbt_file
      ./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_user_tests,ddt_intel/tbt_func_tests -o $TBT_LOG -c
      rm -rf $all_set_txt
      echo "$(date +%m-%d_%H_%M): delete *set*.txt, set secure_set.txt in $BIOS_DATA" >> $run_tbt_file
      echo "next" > $BIOS_DATA/secure_set.txt
      reboot
      ;;
    secure_set_done.txt)
      cd $ddt_path
      echo "secure mode test" >> $run_tbt_file
      echo "./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_secure_tests,ddt_intel/tbt_func_tests -o $TBT_LOG -c" >> $run_tbt_file
      ./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_secure_tests,ddt_intel/tbt_func_tests -o $TBT_LOG -c
      echo "./runtests.sh -p $PF -P $PF -g tbt_common_subset -o $TBT_LOG -c" >> $run_tbt_file
      ./runtests.sh -p $PF -P $PF -g tbt_common_subset -o $TBT_LOG -c
      rm -rf $all_set_txt
      echo "$(date +%m-%d_%H_%M): delete *set*.txt, set dp_set.txt in $BIOS_DATA" >> $run_tbt_file
      echo "next" > $BIOS_DATA/dp_set.txt
      reboot
      ;;
    dp_set_done.txt)
      cd $ddt_path
      echo "dp mode test" >> $run_tbt_file
      echo "./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_dp_tests -o $TBT_LOG -c" >> $run_tbt_file
      ./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_dp_tests -o $TBT_LOG -c
      rm -rf $all_set_txt
      echo "$(date +%m-%d_%H_%M): delete *set*.txt, set all_set_done.txt in $BIOS_DATA" >> $run_tbt_file
      echo "done" > $BIOS_DATA/all_set_done.txt
      ;;
    all_set_done.txt)
      echo "All tbt cases finished, press any key to confirm to rerun, or Ctrl+C if previous step fails"
      read -n1 -r -p "Press any key to continue..." key
      echo "$DATE" > $DATE_FILE
      echo "$DATE: All tbt cases finished, rerun tbt cases at $(date +%m-%d_%H_%M)" >> $run_tbt_file
      echo "next" > $BIOS_DATA/none_set.txt
      reboot
      ;;
    *)
      echo "Rerun tbt cases"
      echo "$DATE: Rerun tbt cases" >> $run_tbt_file
      echo "next" > $BIOS_DATA/none_set.txt
      echo "$DATE" > $DATE_FILE
      reboot
  esac
}

find_usb
test_tbt
