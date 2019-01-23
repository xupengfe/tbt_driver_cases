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
#             July. 27, 2017


# @desc This script verify controllers files exist on sysfs for thunderbolt
# @params None
# @returns Fail the test if return code is non-zero (value set not found)

#source "common.sh"  # Import do_cmd(), die() and other functions
############################# Functions ########################################
TIME_FMT="%Y%m%d-%H%M%S.%N"

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
# Avoid using echo. Instead use print functions provided by st_log.sh
TBT_PATH="/sys/bus/thunderbolt/devices"
REGEX_DEVICE="-"
REGEX_DOMAIN="domain"
#DEVICE_FILES=("authorized" "device" "device_name" "nvm_authenticate" "nvm_version" "uevent" "unique_id" "vendor" "vendor_name")
export DEVICE_FILES="authorized device device_name nvm_authenticate nvm_version uevent unique_id vendor vendor_name power/control"
export POWER_FILES="power/control power/runtime_status power/runtime_enabled"
export DOMAIN_FILES="security uevent"
AUTHORIZE_FILE="authorized"
TOPO_FILE="/tmp/tbt_topo.txt"

rm -rf /root/test_tbt_1.log
pci_result=$(lspci -t)
test_print_trc "lspci -t: $pci_result"

enable_authorized()
{
local AIM_FOLDERS
AIM_FOLDERS=$(ls -1 ${TBT_PATH} \
              | grep "$REGEX_DEVICE" \
              | awk '{ print length(), $0 | "sort -n" }' \
              | cut -d ' ' -f 2)

[ -z "$AIM_FOLDERS" ] && test_print_trc "Device folder is not exist" && return 1
#for AIM_FOLDER in $(ls "$TBT_PATH" | grep "$REGEX_TARGET")
for AIM_FOLDER in ${AIM_FOLDERS}
#for AIM_FOLDER in $(ls "$TBT_PATH"/*"$REGEX_TARGET"*)
do
  if [ -e "${TBT_PATH}/${AIM_FOLDER}/${AUTHORIZE_FILE}" ];then
    AUTHORIZE_INFO=$(cat "${TBT_PATH}/${AIM_FOLDER}/${AUTHORIZE_FILE}")
    if [ "$AUTHORIZE_INFO" == "0" ]; then
      test_print_trc "Change 0 to 1 for file: ${TBT_PATH}/${AIM_FOLDER}/${AUTHORIZE_FILE}"
      echo 1 > "${TBT_PATH}/${AIM_FOLDER}/${AUTHORIZE_FILE}" || \
      test_print_trc "Change ${TBT_PATH}/${AIM_FOLDER}/${AUTHORIZE_FILE} failed!"
      sleep 5
    else
      test_print_trc "${TBT_PATH}/${AIM_FOLDER}/${AUTHORIZE_FILE}: ${AUTHORIZE_INFO}"
    fi
  fi
done
}

check_device_sysfs()
{
REGEX_TARGET=$1
AIM_FILE=$2
test_print_trc "____________________Now Cheking '$AIM_FILE'___________________"
local AIM_FOLDERS
AIM_FOLDERS=$(ls -1 ${TBT_PATH} \
              | grep "$REGEX_TARGET" \
              | awk '{ print length(), $0 | "sort -n" }' \
              | cut -d ' ' -f 2)

[ -z "$AIM_FOLDERS" ] && test_print_trc "AIM floder is not exist" && return 1
for AIM_FOLDER in ${AIM_FOLDERS}
#for AIM_FOLDER in $(ls "$TBT_PATH" | grep "$REGEX_TARGET")
do
    #test_print_trc "---Folder For TBT: $AIM_FOLDER"
    #AIM_FOLDER_INFO=$(udevadm info --attribute-walk --path=${TBT_PATH}/"$AIM_FOLDER")
    #AIM_FOLDER_PATH=$(echo "$AIM_FOLDER_INFO" | grep looking | head  -n1 | awk -F "'" '{print $2}')
    #test_print_trc "TBT_FOLDER $AIM_FOLDER real Path: /sys$AIM_FOLDER_PATH"
    if [ -e "${TBT_PATH}/${AIM_FOLDER}/${AIM_FILE}" ];then
      #test_print_trc "File $AIM_FILE is found on $TBT_PATH/$AIM_FOLDER"
      FILE_INFO=$(cat ${TBT_PATH}/"$AIM_FOLDER"/"$AIM_FILE")
      if [ "$FILE_INFO" != "" ]; then
        test_print_trc "${TBT_PATH}/${AIM_FOLDER}/${AIM_FILE}:   |$FILE_INFO"
      else
        test_print_trc "TBT file $TBT_PATH/${AIM_FOLDER}/${AIM_FILE} is null, should not be null"
        return 1
      fi
    else
      test_print_trc "File $AIM_FILE is not found or not a file on $TBT_PATH/$AIM_FOLDER"
      continue
    fi
done
return $?
}

fill_key()
{
  local source_key=$1
  local aim_folder=$2
  local key_file="key"
  local key_path="$HOME/keys"
  local home_key=""
  local verify_key=""
  cat ${key_path}/${source_key} > ${TBT_PATH}/${aim_folder}/${key_file}
  home_key=$(cat ${key_path}/${source_key})
  verify_key=$(cat ${TBT_PATH}/${aim_folder}/${key_file})
  test_print_trc "${key_path}/${source_key}:$home_key"
  test_print_trc "${TBT_PATH}/${aim_folder}/${key_file}:$verify_key"
}

verify_key_file()
{
  local key_file="key"
  local key_path="$HOME/keys"
  local aim_folder=$1
  local key_content=""
  local key_len=""
  local return_result=""
  local author_result=""
  local author_file="authorized"

  if [ -e "${TBT_PATH}/${aim_folder}/${key_file}" ];then
    check_32bytes_key "${key_path}/${aim_folder}.key"
    return_result=$?
    if [ $return_result -ne 0 ]; then
      test_print_trc "Return_result: $return_result"
      fill_key "${aim_folder}.key" "$aim_folder"
      echo 1 > ${TBT_PATH}/${aim_folder}/${author_file}
      sleep 3
    else
      fill_key "${aim_folder}.key" "$aim_folder"
      test_print_trc "fill 2 into ${TBT_PATH}/${aim_folder}/${author_file}:"
      echo 2 > ${TBT_PATH}/${aim_folder}/${author_file}
      sleep 3
      author_result=$(cat ${TBT_PATH}/${aim_folder}/${author_file})
      test_print_trc "${TBT_PATH}/${aim_folder}/${author_file}:$author_result"
    fi
  else
    test_print_trc "File key is not found on $TBT_PATH/$aim_folder"
  fi
}

check_security_mode()
{
  DOMAIN="domain0/security"
  [ -e ${TBT_PATH}/${DOMAIN} ] && SECURITY_RESULT=$(cat ${TBT_PATH}/${DOMAIN})
  [ -z "$SECURITY_RESULT" ] && test_print_trc "SECURITY_RESULT is null." && \
    return 1
  echo "$SECURITY_RESULT"
}

check_device_file()
{
#for DEVICE_FILE in "${DEVICE_FILES[@]}"
for DEVICE_FILE in ${DEVICE_FILES}
do
  check_device_sysfs "$REGEX_DEVICE" "$DEVICE_FILE"
done
test_print_trc "Check power sysfs files"

for POWER_FILE in ${POWER_FILES}
do
  check_device_sysfs "$REGEX_DEVICE" "$POWER_FILE"
done
}

check_domain_file()
{
#for DOMAIN_FILE in "${DOMAIN_FILES[@]}"
for DOMAIN_FILE in ${DOMAIN_FILES}
do
  check_device_sysfs "$REGEX_DOMAIN" "$DOMAIN_FILE"
done
}

check_32bytes_key()
{
  local key_file=$1
  local key_content=""
  local key_len=""
  local key_number=64

  if [ -e "$key_file" ]; then
    test_print_trc "$key_file already exist"
    key_content=$(cat ${key_file})
    key_len=${#key_content}
    if [ "$key_len" -eq "$key_number" ]; then
      test_print_trc "$key_file lenth is 64, ok"
      return 0
    else
      test_print_trc "$key_file lenth is not 64:$key_content"
      test_print_trc "Key lenth wrong, regenerate $key_file"
      openssl rand -hex 32 > $key_file
      return 2
    fi
  else
    test_print_trc "No key file, generate $key_file"
    openssl rand -hex 32 > $key_file
    return 1
  fi
}

wrong_password_check()
{
  local key_file="key"
  local key_path="$HOME/keys"
  local aim_folder=$1
  local error_key="error.key"
  local key_content=""
  local key_len=""
  local compare=""
  local author_result=""
  local author_file="authorized"

  if [ -e "${TBT_PATH}/${aim_folder}/${key_file}" ];then
    if [ -e "${TBT_PATH}/${aim_folder}/${author_file}" ]; then
      author_result=$(cat ${TBT_PATH}/${aim_folder}/${author_file})
      if [ "$author_result" != "0" ]; then
        test_print_trc "${TBT_PATH}/${aim_folder}/${author_file}:$author_result"
        test_print_trc "authorized already passed, skip"
        author_result=""
        return 1
      else
        author_result=""
      fi
    fi

    check_32bytes_key "${key_path}/${error_key}"
    if [ -e "${key_path}/${aim_folder}.key" ]; then
      compare=$(diff ${key_path}/${error_key} ${key_path}/${aim_folder}.key)
      if [ -z "$compare" ]; then
        test_print_trc "${key_path}/${error_key} the same as correct one, regenerate"
        openssl rand -hex 32 > ${key_path}/${error_key}
      fi
    fi
    fill_key "$error_key" "$aim_folder"
    test_print_trc "fill 2 into ${TBT_PATH}/${aim_folder}/${author_file}:"
    echo 2 > ${TBT_PATH}/${aim_folder}/${author_file}
    sleep 1
    author_result=$(cat ${TBT_PATH}/${aim_folder}/${author_file})
    if [ "$author_result" == "0" ]; then
      test_print_trc "${TBT_PATH}/${aim_folder}/${author_file}:$author_result passed"
    else
      test_print_trc "${TBT_PATH}/${aim_folder}/${author_file}:$author_result failed"
    fi

  else
    test_print_trc "File key is not found on $TBT_PATH/$aim_folder"
  fi
}

wrong_password_test()
{
  local key_path="$HOME/keys"
  local regex_target=$REGEX_DEVICE
  local aim_folder=""
  local aim_folders=""
  local author_file="authorized"

  test_print_trc "Secure mode wrong passsword test next:"
  aim_folders=$(ls -1 ${TBT_PATH} \
                | grep "$regex_target" \
                | awk '{ print length(), $0 | "sort -n" }' \
                | cut -d ' ' -f 2)

  [ -z "$aim_folders" ] && test_print_trc "AIM floder is not exist" && return 1
  [ -d "$key_path" ] || mkdir "$key_path"

  for aim_folder in ${aim_folders}; do
    wrong_password_check "$aim_folder"
  done
}

secure_mode_test()
{
  local key_path="$HOME/keys"
  local regex_target=$REGEX_DEVICE
  local aim_folder=""
  local aim_folders=""
  local author_file="authorized"
  local time=3
  local author_path="/sys/bus/thunderbolt/devices/*/authorized"
  local result=""

  test_print_trc "Secure mode verify correct passsword test next:"
  aim_folders=$(ls -1 ${TBT_PATH} \
                | grep "$regex_target" \
                | awk '{ print length(), $0 | "sort -n" }' \
                | cut -d ' ' -f 2)
  [ -z "$aim_folders" ] && test_print_trc "AIM floder is not exist" && return 1
  [ -d "$key_path" ] || mkdir "$key_path"

  for((i=1; i<=time; i++)); do
    result=$(grep -H . ${author_path} 2>/dev/null |awk -F ':' '{print $NF}' | grep 0)
    if [ -z "$result" ]; then
      test_print_trc "authorized all ok"
      break
    else
      test_print_trc "$i round set 2 to authorized for secure mode:"
      for aim_folder in ${aim_folders}; do
        verify_key_file "$aim_folder"
        if [ $? -ne 0 ]; then
          test_print_trc "Action result abnormal, please check the detail log"
        fi
      done
    fi
  done
  if [ $i -ge $time ]; then
    test_print_trc "Need check log carefully i reach $i"
    test_print_trc "It's better unplug and plug the TBT devices and test again!"
    enable_authorized
  fi
}


# This function will view request domain and request tbt branch devices
# and will write the topo result into $TOPO_FILE
# Inuput:
#   $1: domain num, 0 for domain0, 1 for domain1
#   $2: branch num, 1 for domainX-1, 3 for domainX-3
# Return: 0 for true, otherwise false or die
topo_view() {
  local domainx=$1
  local tn=$2
  local tbt_sys=""
  local tbt_file=""
  local dev_name="device_name"
  local device_topo=""
  local file_topo=""
  local device_num=""

  # Get tbt sys file in connection order
  tbt_sys=$(ls -l ${TBT_PATH}/${domainn}*${tn} 2>/dev/null \
            | grep "-" \
            | awk '{ print length(), $0 | "sort -n" }' \
            | tail -n 1 \
            | awk -F "${REGEX_DOMAIN}${domainx}/" '{print $2}' \
            | tr '/' ' ')

  [ -n "$tbt_sys" ] || {
    test_print_trc "No tbt device in $domainx-$tn!"
    return 1
  }

  # Get last file
  last=$(echo $tbt_sys | awk '{print $NF}')
  device_num=$(echo $tbt_sys | awk '{print NF-1}')
  test_print_trc "$domainx-$tn contain $device_num tbt devices:"
  echo "$domainx-$tn contain $device_num tbt devices:" >> $TOPO_FILE

  # Last file not add <-> in the end
  for tbt_file in ${tbt_sys}; do
    if [ "$tbt_file" == "$last" ]; then
      device_file=$(cat ${TBT_PATH}/${tbt_file}/${dev_name})
      device_topo=${device_topo}${device_file}
      file_topo=${file_topo}${tbt_file}
    else
      device_file=$(cat ${TBT_PATH}/${tbt_file}/${dev_name})
      # For alignment for such as 0-0 and device name, device name is longer
      device_file_num=${#device_file}
      tbt_file_num=${#tbt_file}
      if [ $device_file_num -gt $tbt_file_num ]; then
        gap=$((device_file_num - tbt_file_num))
        device_topo=${device_topo}${device_file}" <-> "
        file_topo=${file_topo}${tbt_file}
        for ((c=1; c<=gap; c++)); do
          file_topo=${file_topo}" "
        done
        file_topo=${file_topo}" <-> "
      else
        device_topo=${device_topo}${device_file}" <-> "
        file_topo=${file_topo}${tbt_file}" <-> "
      fi
    fi
  done
  test_print_trc "device_topo: $device_topo"
  echo "device_topo: $device_topo" >> $TOPO_FILE
  test_print_trc "file_topo  : $file_topo"
  echo "file_topo  : $file_topo" >> $TOPO_FILE
}

# This function will check how many tbt device connected and
# show the tbt devices how to connect, which one connect with which one
# Inuput: NA
# Return: 0 for true, otherwise false or die
topo_tbt_show(){
  # tbt spec design tbt each domain will seprate to like 0-1 or 0-3 branch
  local t1="1"
  local t3="3"
  local domains=""
  local domain=""
  local topo_result=""

  domains=$(ls $TBT_PATH/ \
            | grep "$REGEX_DOMAIN" \
            | awk -F "$REGEX_DOMAIN" '{print $2}' \
            | awk -F "->" '{print $1}')

  cat /dev/null > $TOPO_FILE

  for domain in ${domains}; do
    topo_view "$domain" "$t1"
    topo_view "$domain" "$t3"
  done
  topo_result=$(cat $TOPO_FILE)
  [[ -n "$topo_result" ]] || { 
    echo "tbt $TOPO_FILE is null:$topo_result!!!"
  }
}

topo_tbt_show_old() {
  local tbt_sys=""
  local tbt_file=""
  local dev_name="device_name"
  local device_topo=""
  local file_topo=""
  local device_num=""

  # Get tbt sys file in connection order
  tbt_sys=$(ls -1 ${TBT_PATH} \
            | grep '-' \
            | awk '{ print length(), $0 | "sort -n" }' \
            | cut -d ' ' -f 2)
  #tbt_sys=$(echo "$tbt_sys" | tr '\n' ' ')
  #test_print_trc "tbt_sys:$tbt_sys"
  # Get last file
  last=$(echo $tbt_sys | awk '{print $NF}')
  device_num=$(echo $tbt_sys | awk '{print NF-1}')
  #test_print_trc "last: $last, device_num:$device_num"
  test_print_trc "***  $device_num TBT devices detected as below  ***"

  # Last file not add <->
  for tbt_file in ${tbt_sys}; do
    if [ "$tbt_file" == "$last" ]; then
      device_file=$(cat ${TBT_PATH}/${tbt_file}/${dev_name})
      device_topo=${device_topo}${device_file}
      file_topo=${file_topo}${tbt_file}
    else
      device_file=$(cat ${TBT_PATH}/${tbt_file}/${dev_name})
      device_file_num=${#device_file}
      tbt_file_num=${#tbt_file}
      if [ $device_file_num -gt $tbt_file_num ]; then
        gap=$((device_file_num - tbt_file_num))
        device_topo=${device_topo}${device_file}" <-> "
        file_topo=${file_topo}${tbt_file}
        for ((c=1; c<=gap; c++)); do
          file_topo=${file_topo}" "
        done
        file_topo=${file_topo}" <-> "
      else
        device_topo=${device_topo}${device_file}" <-> "
        file_topo=${file_topo}${tbt_file}" <-> "
      fi
    fi
  done
test_print_trc "device_topo: $device_topo"
test_print_trc "file_topo  : $file_topo"
}

tbt_main()
{
  SECURITY=$(check_security_mode)
  if [ "$SECURITY" == "user" ]; then
    for ((i = 1; i <= 10; i++))
    do
      CHECK_RESULT=$(cat ${TBT_PATH}/*/${AUTHORIZE_FILE} | grep 0)
      if [ -z "$CHECK_RESULT" ]; then
        test_print_trc "All authorized set to 1"
        break
      else
        test_print_trc "$i round to enable authorized"
        enable_authorized
      fi
    done
  elif [ "$SECURITY" == "none" ]; then
    test_print_trc "Security Mode: $SECURITY"
    #check_authorized
  elif [ "$SECURITY" == "secure" ]; then
    test_print_trc "Security Mode: $SECURITY"
    wrong_password_test
    secure_mode_test
  elif [ "$SECURITY" == "dponly" ]; then
    test_print_trc "Security Mode: $SECURITY"
  else
    test_print_trc "Get wrong mode: $SECURITY"
    return 1
  fi
  check_device_file
  check_domain_file
  topo_tbt_show
}

check_device_file
check_domain_file
topo_tbt_show
tbt_main
