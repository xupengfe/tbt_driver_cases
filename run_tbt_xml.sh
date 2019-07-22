#!/bin/bash

BIOS_USB_NODE=""
LINUX_VER=$(uname -r)
DATE=$(date +%m-%d_%H_%M)
LOG_PATH="/opt/logs/TBT_LOG"
TBT_LOG="/opt/logs/TBT_${LINUX_VER}_${DATE}"
BIOS_DATA="/data_tbt"
DATE_FILE="${BIOS_DATA}/date"
TBT_COMMONS="tbt_secure_tests tbt_bat_tests tbt_func_tests tbt_userspace_tests tbt_hotplug_tests tbt_rtd3_tests tbt_suspend_resume_tests tbt_preboot_tests tbt_vtd_tests"
RUN_TBT_FILE="${LOG_PATH}/run_tbt_xml.log"
PF_FILE="${BIOS_DATA}/platform"
ONLY_MODE="mode_set.txt"
ONLY_SET="only_set.txt"
PF=$1
FUNC=$2

usage() {
  cat <<__EOF
  usage: ./${0##*/} platform_rvp FUNC
    platform_rvp: example cfl-h-rvp | whl-u-rvp | cml-u-rvp | aml-y-rvp | icl-u-rvp
    FUNC: optional example none|user|secure|dp or rerun | clear
__EOF
}

check_tbt_folder() {
  [[ -d "$BIOS_DATA" ]] || {
    echo "mkdir $BIOS_DATA"
    mkdir $BIOS_DATA
  }

  [[ -e "$BIOS_DATA/set_none.ini" ]] || {
    echo "No $BIOS_DATA/set_none.ini file, exit"
    exit 2
  }

  [[ -e "$BIOS_DATA/set_user.ini" ]] || {
    echo "No $BIOS_DATA/set_user.ini file, exit"
    exit 2
  }

  [[ -e "$BIOS_DATA/set_secure.ini" ]] || {
    echo "No $BIOS_DATA/set_secure.ini file, exit"
    exit 2
  }

  [[ -e "$BIOS_DATA/set_dp.ini" ]] || {
    echo "No $BIOS_DATA/set_dp.ini file, exit"
    exit 2
  }
}

check_pf() {
  if [[ -n "$PF" ]]; then
    [[ "$PF" == *"rvp"* ]] || {
      echo "PF:$PF, pltform was not correct! exit"
      usage
      exit 3
  }

  check_tbt_folder
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
  ddt_path=$(ls -1 /home/* | grep ^/home | grep "ltp-ddt_" | tail -n 1 | cut -d ':' -f 1)
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
  echo "$DATE, ddt path:$ddt_path, $tbt_done_file" >> $RUN_TBT_FILE


  case ${FUNC} in
    none|user|secure|dp)
      rm -rf $all_set_txt
      echo "$(date +%m-%d_%H_%M): FUNC:$FUNC, set_${FUNC}.ini and ${ONLY_MODE} in $BIOS_DATA" >> $RUN_TBT_FILE
      echo "next" > ${BIOS_DATA}/${FUNC}_set.txt
      echo "only" > ${BIOS_DATA}/${ONLY_MODE}
      reboot
      ;;
    set_none|set_user|set_secure|set_dp)
      rm -rf $all_set_txt
      echo "$(date +%m-%d_%H_%M): FUNC:$FUNC, set_${FUNC}.ini and ${ONLY_SET} in $BIOS_DATA" >> $RUN_TBT_FILE
      #set bios
      echo "only" > ${BIOS_DATA}/${ONLY_SET}
      reboot
      ;;
    rerun)
      rm -rf $all_set_txt
      echo "$(date +%m-%d_%H_%M): FUNC:$FUNC, rerun! Set none_set.txt in $BIOS_DATA" >> $RUN_TBT_FILE
      echo "next" > $BIOS_DATA/none_set_done.txt
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
}

check_pf
check_tbt_folder

test_tbt
