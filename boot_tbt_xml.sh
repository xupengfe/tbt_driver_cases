#!/bin/bash

BIOS_USB_NODE=""
LINUX_VER=$(uname -r)
DATE=$(date +%m-%d_%H_%M)
LOG_PATH="/opt/logs/TBT_LOG"
TBT_LOG="/opt/logs/TBT_${LINUX_VER}_${DATE}"
BIOS_DATA="/data_tbt"
DATE_FILE="${BIOS_DATA}/date"
RUN_TBT_FILE="${LOG_PATH}/run_tbt_xml.log"
TBT_COMMONS="tbt_secure_tests tbt_bat_tests tbt_func_tests tbt_userspace_tests tbt_hotplug_tests tbt_rtd3_tests tbt_suspend_resume_tests tbt_preboot_tests tbt_vtd_tests"
PF_FILE="${BIOS_DATA}/platform"
ONLY_MODE="mode_set.txt"
ONLY_SET="only_set.txt"
PF=""

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

find_pf() {
  [[ -e "$PF_FILE" ]] || {
    echo "file ${PF_FILE} could not find at $(date +%m-%d_%H_%M)" >> $RUN_TBT_FILE
    exit 1
  }
  PF=$(cat ${PF_FILE})
  [[ -n "$PF" ]] || {
    echo "PF is null:$PF, exit at $(date +%m-%d_%H_%M)" >> $RUN_TBT_FILE
    exit 1
  }
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

  [[ -e "$BIOS_DATA/$ONLY_SET" ]] && {
    echo "$DATE, $BIOS_DATA/$ONLY_SET exist, rm $BIOS_DATA/$all_set_txt" >> $RUN_TBT_FILE
    rm -rf $BIOS_DATA/$all_set_txt
    exit 0
  }

  [[ -z "$PF" ]] && PF="cfl-h-rvp"
  cd $BIOS_DATA
  tbt_done_file=$(ls -1 *set_done.txt 2>/dev/null)
  echo >> $RUN_TBT_FILE
  echo "**********************************" >> $RUN_TBT_FILE
  echo "$DATE, ddt path:$ddt_path" >> $RUN_TBT_FILE

  case ${tbt_done_file} in
    none_set_done.txt)
      cd $ddt_path
      echo "none mode test" >> $RUN_TBT_FILE
      echo "./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_none_tests -o $TBT_LOG -c" >> $RUN_TBT_FILE
      ./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_none_tests -o $TBT_LOG -c
      #echo "./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_func_tests -o $TBT_LOG -c" >> $RUN_TBT_FILE
      #./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_func_tests -o $TBT_LOG -c

      dmesg > "${TBT_LOG}/dmesg_none_${present_date}.txt"
      echo "record dmesg:${TBT_LOG}/dmesg_none_${present_date}.txt"

      if [[ -e "${BIOS_DATA}/${ONLY_MODE}" ]]; then
        echo "$(date +%m-%d_%H_%M): contain ${ONLY_MODE}, delete *set*.txt" >> $RUN_TBT_FILE
        rm -rf $all_set_txt
        exit 0
      else
        echo "$(date +%m-%d_%H_%M): delete *set*.txt, set user mode bios" >> $RUN_TBT_FILE
        rm -rf $all_set_txt
	echo "$(date +%m-%d_%H_%M): boot_tbt_xml: bios-tbt.py -i ${BIOS_DATA}/set_user.ini" >> $RUN_TBT_FILE
        bios-tbt.py -i ${BIOS_DATA}/set_user.ini
	echo "next" > ${BIOS_DATA}/user_set_done.txt
	sleep 1
        reboot
      fi
      echo "$(ls $BIOS_DATA)" >> $RUN_TBT_FILE
      ;;
    user_set_done.txt)
      cd $ddt_path
      echo "user mode test" >> $RUN_TBT_FILE
      echo "./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_user_tests -o $TBT_LOG -c" >> $RUN_TBT_FILE
      ./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_user_tests -o $TBT_LOG -c

      dmesg > "${TBT_LOG}/dmesg_user_${present_date}.txt"
      echo "record dmesg:${TBT_LOG}/dmesg_user_${present_date}.txt"

      if [[ -e "${BIOS_DATA}/${ONLY_MODE}" ]]; then
        echo "$(date +%m-%d_%H_%M): contain ${ONLY_MODE}, delete *set*.txt" >> $RUN_TBT_FILE
        rm -rf $all_set_txt
        exit 0
      else
        echo "$(date +%m-%d_%H_%M): delete *set*.txt, set secure mode bios" >> $RUN_TBT_FILE
        rm -rf $all_set_txt
	echo "$(date +%m-%d_%H_%M): boot_tbt_xml: bios-tbt.py -i ${BIOS_DATA}/set_secure.ini" >> $RUN_TBT_FILE
	bios-tbt.py -i ${BIOS_DATA}/set_secure.ini
	echo "next" > ${BIOS_DATA}/secure_set_done.txt
        reboot
      fi
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

      dmesg > "${TBT_LOG}/dmesg_secure_${present_date}.txt"
      echo "record dmesg:${TBT_LOG}/dmesg_secure_${present_date}.txt"

      if [[ -e "${BIOS_DATA}/${ONLY_MODE}" ]]; then
        echo "$(date +%m-%d_%H_%M): contain ${ONLY_MODE}, delete *set*.txt" >> $RUN_TBT_FILE
        rm -rf $all_set_txt
        exit 0
      else
        echo "$(date +%m-%d_%H_%M): delete *set*.txt, set dp mode bios" >> $RUN_TBT_FILE
        rm -rf $all_set_txt
	echo "$(date +%m-%d_%H_%M): boot_tbt_xml: bios-tbt.py -i ${BIOS_DATA}/set_dp.ini" >> $RUN_TBT_FILE
	bios-tbt.py -i ${BIOS_DATA}/set_dp.ini
	echo "next" > ${BIOS_DATA}/dp_set_done.txt
        reboot
      fi
      ;;
    dp_set_done.txt)
      cd $ddt_path
      echo "dp mode test" >> $RUN_TBT_FILE
      echo "./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_dp_tests -o $TBT_LOG -c" >> $RUN_TBT_FILE
      ./runtests.sh -p $PF -P $PF -f ddt_intel/tbt_dp_tests -o $TBT_LOG -c

      dmesg > "${TBT_LOG}/dmesg_dp_${present_date}.txt"
      echo "record dmesg:${TBT_LOG}/dmesg_dp_${present_date}.txt"

      if [[ -e "${BIOS_DATA}/${ONLY_MODE}" ]]; then
        echo "$(date +%m-%d_%H_%M): contain ${ONLY_MODE}, delete *set*.txt" >> $RUN_TBT_FILE
        rm -rf $all_set_txt
      else
        echo "$(date +%m-%d_%H_%M): delete *set*.txt, set all_set_done.txt in $BIOS_DATA" >> $RUN_TBT_FILE
        rm -rf $all_set_txt
        echo "done" > $BIOS_DATA/all_set_done.txt
      fi
      ;;
    all_set_done.txt)
      echo "All tbt cases finished"
      echo "$DATE: All tbt cases finished preset time $(date +%m-%d_%H_%M), systemd tbt exit" >> $RUN_TBT_FILE
      exit 0
      ;;
    *)
      echo "$DATE: no useful *set_done.txt, systemd tbt exit, present time $(date +%m-%d_%H_%M)" >> $RUN_TBT_FILE
      exit 0
  esac
}

check_tbt_folder
find_pf
test_tbt
