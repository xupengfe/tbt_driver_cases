#!/bin/bash

BIOS_USB_NODE=""
LINUX_VER=$(uname -r)
DATE=$(date +%m-%d_%H_%M)
LOG_PATH="/opt/logs/TBT_LOG"
TBT_LOG="/opt/logs/TBT_${LINUX_VER}_${DATE}"
BIOS_DATA="/bios_data"
DATE_FILE="${BIOS_DATA}/date"
TBT_COMMONS="tbt_secure_tests tbt_bat_tests tbt_func_tests tbt_userspace_tests tbt_hotplug_tests tbt_rtd3_tests tbt_suspend_resume_tests tbt_preboot_tests tbt_nvm_tests tbt_vtd_tests"
RUN_TBT_FILE="${LOG_PATH}/run_tbt.log"
PF_FILE="${BIOS_DATA}/platform"
PF=$1
FUNC=$2

usage() {
  cat <<__EOF
  usage: ./${0##*/} platform_rvp FUNC
    platform_rvp: example cfl-h-rvp | whl-u-rvp | cml-u-rvp | aml-y-rvp | icl-u-rvp
    FUNC: optional example none|user|secure|dp or rerun | clear
__EOF
}

find_usb() {
  nodes=$(ls -1 /dev/sd* | awk -F "/dev/" '{print $2}')
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

  umount -f $BIOS_DATA

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

check_pf() {
  if [[ -n "$PF" ]]; then
    [[ "$PF" == *"rvp"* ]] || {
      echo "PF:$PF, pltform was not correct! exit"
      usage
      exit 3
  }

  find_usb
  echo "set $PF in ${PF_FILE} at $(date +%Y-%m-%d_%H_%M)" >> $RUN_TBT_FILE
  echo "$PF" > ${PF_FILE}
  else
    echo "PF not defined when execute script"
    usage
    exit 2
  fi
}

test_tbt() {
  tbt_done_file=""
  ddt_path=$(ls -1 /home/ltp-ddt_* | grep ^/home | tail -n 1 | cut -d ':' -f 1)
  all_set_txt="${BIOS_DATA}/*set*.txt"
  origin_date=$(cat $DATE_FILE)
  tbt_common=""
  tbt_log_file=""
  present_date=$(date +%m-%d_%H_%M)

  if [[ -z "$origin_date" ]]; then
    TBT_LOG="/opt/logs/TBT_${LINUX_VER}_${DATE}"
  else
    TBT_LOG="/opt/logs/TBT_${LINUX_VER}_${origin_date}"
  fi

  [[ -d "$LOG_PATH" ]] || {
    echo "No folder $LOG_PATH exist, create it"
    mkdir -p $LOG_PATH
  }

  cd $BIOS_DATA
  tbt_done_file=$(ls -1 *set_done.txt)
  echo >> $RUN_TBT_FILE
  echo "**********************************" >> $RUN_TBT_FILE
  echo "$DATE, ddt path:$ddt_path" >> $RUN_TBT_FILE


  case ${FUNC} in
    none|user|secure|dp)
      rm -rf $all_set_txt
      echo "$(date +%m-%d_%H_%M): FUNC:$FUNC, set ${FUNC}_set.txt in $BIOS_DATA" >> $RUN_TBT_FILE
      echo "next" > $BIOS_DATA/${FUNC}_set.txt
      reboot
      ;;
    rerun)
      rm -rf $all_set_txt
      echo "$(date +%m-%d_%H_%M): FUNC:$FUNC, rerun! Set none_set.txt in $BIOS_DATA" >> $RUN_TBT_FILE
      echo "next" > $BIOS_DATA/none_set.txt
      echo "$DATE" > $DATE_FILE
      reboot
      ;;
    clear)
      rm -rf $all_set_txt
      echo "$(date +%m-%d_%H_%M): FUNC:$FUNC, clear! Clean set txt and set all_set_done.txt in $BIOS_DATA"
      echo "next" > $BIOS_DATA/all_set_done.txt
      echo "$DATE" > $DATE_FILE
      exit 0
      ;;
    *)
      echo "FUNC:$FUNC" >> $RUN_TBT_FILE
      ;;
  esac

  case ${tbt_done_file} in
    none_set_done.txt)
      cd $ddt_path
      echo "none mode test" >> $RUN_TBT_FILE
      echo "./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_none_tests -o $TBT_LOG -c" >> $RUN_TBT_FILE
      ./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_none_tests,ddt_intel/tbt_func_tests -o $TBT_LOG -c
      echo "./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_func_tests -o $TBT_LOG -c" >> $RUN_TBT_FILE
      ./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_func_tests -o $TBT_LOG -c
      rm -rf $all_set_txt
      echo "$(date +%m-%d_%H_%M): delete *set*.txt, set user_set.txt in $BIOS_DATA" >> $RUN_TBT_FILE
      echo "next" > $BIOS_DATA/user_set.txt
      ls $BIOS_DATA
      echo "$(ls $BIOS_DATA)" >> $RUN_TBT_FILE
      dmesg > "${TBT_LOG}/dmesg_none_${present_date}.txt"
      echo "record dmesg:${TBT_LOG}/dmesg_none_${present_date}.txt"
      reboot
      ;;
    user_set_done.txt)
      cd $ddt_path
      echo "user mode test" >> $RUN_TBT_FILE
      echo "./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_user_tests -o $TBT_LOG -c" >> $RUN_TBT_FILE
      ./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_user_tests,ddt_intel/tbt_func_tests -o $TBT_LOG -c
      rm -rf $all_set_txt
      echo "$(date +%m-%d_%H_%M): delete *set*.txt, set secure_set.txt in $BIOS_DATA" >> $RUN_TBT_FILE
      echo "next" > $BIOS_DATA/secure_set.txt
      dmesg > "${TBT_LOG}/dmesg_user_${present_date}.txt"
      echo "record dmesg:${TBT_LOG}/dmesg_user_${present_date}.txt"
      reboot
      ;;
    secure_set_done.txt)
      cd $ddt_path
      echo "secure mode test" >> $RUN_TBT_FILE

      for tbt_common in ${TBT_COMMONS}; do
        tbt_log_file="DDT_${tbt_common}.log"
        if [[ -e "${TBT_LOG}/${tbt_log_file}" ]]; then
          echo "Already ran ${TBT_LOG}/${tbt_log_file}, skip at  $(date +%m-%d_%H_%M)" >> $RUN_TBT_FILE
          continue
        else
          echo "./runtests.sh -p $PF -P $PF -f ddt_intel/${tbt_common} -o $TBT_LOG -c" >> $RUN_TBT_FILE
          ./runtests.sh -p $PF -P $PF -f ddt_intel/${tbt_common} -o $TBT_LOG -c
        fi
      done

      rm -rf $all_set_txt
      echo "$(date +%m-%d_%H_%M): delete *set*.txt, set dp_set.txt in $BIOS_DATA" >> $RUN_TBT_FILE
      echo "next" > $BIOS_DATA/dp_set.txt
      dmesg > "${TBT_LOG}/dmesg_secure_${present_date}.txt"
      echo "record dmesg:${TBT_LOG}/dmesg_secure_${present_date}.txt"
      reboot
      ;;
    dp_set_done.txt)
      cd $ddt_path
      echo "dp mode test" >> $RUN_TBT_FILE
      echo "./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_dp_tests -o $TBT_LOG -c" >> $RUN_TBT_FILE
      ./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_dp_tests -o $TBT_LOG -c
      rm -rf $all_set_txt
      echo "$(date +%m-%d_%H_%M): delete *set*.txt, set all_set_done.txt in $BIOS_DATA" >> $RUN_TBT_FILE
      echo "done" > $BIOS_DATA/all_set_done.txt
      dmesg > "${TBT_LOG}/dmesg_dp_${present_date}.txt"
      echo "record dmesg:${TBT_LOG}/dmesg_dp_${present_date}.txt"
      ;;
    all_set_done.txt)
      echo "All tbt cases finished, press any key to confirm to rerun, or Ctrl+C if you don't want to rerun TBT cases"
      read -n1 -r -p "Press any key to continue..." key
      echo "$DATE" > $DATE_FILE
      echo "$DATE: All tbt cases finished, rerun tbt cases at $(date +%m-%d_%H_%M)" >> $RUN_TBT_FILE
      rm -rf $all_set_txt
      echo "next" > $BIOS_DATA/none_set.txt
      reboot
      ;;
    *)
      echo "Rerun tbt cases"
      echo "$DATE: Rerun tbt cases" >> $RUN_TBT_FILE
      rm -rf $all_set_txt
      echo "next" > $BIOS_DATA/none_set.txt
      echo "$DATE" > $DATE_FILE
      reboot
  esac
}

check_pf
find_usb

test_tbt
