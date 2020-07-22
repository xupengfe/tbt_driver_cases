#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

# Generate full bios items ini or compare 2 ini to get differences ini
# Pengfei, Xu  <pengfei.xu@intel.com>

SOUREC_FILE=""
GEN_FILE=""
NAMES=""
SECURE_NAME="SecurityMode"
BIOS_DATA="/data_tbt"

usage() {
  cat <<__EOF
  usage: ./${0##*/} [-f XML_FILE][-c CURRENT_INI][-t TARGET_INI][-o output.ini]
    -f XML_FILE: will generate full bios item ini
    -c CURRENT_INI -t TARGET_INI: will compare both and generate delta target ini
    -s TARGET_INI: will generate none/user/secure/dp ini into /data_tbt
    -o output.ini, if no -o item will set bios.ini as default
__EOF
  exit 2
}

generate_ini() {
  name=""
  NAMES=$(cat $SOUREC_FILE | grep " name=\"" | awk -F "name=" '{print $2}' | awk -F '\"' '{print $2}')
  value=""

  [[ -n "$GEN_FILE" ]] || {
    echo "No -o setting, set bios.ini as default output ini file"
    GEN_FILE="bios.ini"
  }

  cat /dev/null > $GEN_FILE
  echo "[BiosKnobs]" >> $GEN_FILE
  for name in ${NAMES}; do
    value=""
    value=$(cat "$SOUREC_FILE" | grep "name=\"$name\"" | awk -F "CurrentVal=" '{print $2}' | awk -F '\"' '{print $2}' | tail -n 1)
    [[ -n "$value" ]] || echo "Warning!!! $name in $TARGET_FILE is null"
    echo "${name}=$value" >> $GEN_FILE
  done

  echo "Done. Generated $GEN_FILE"
}

compare_ini() {
  target_items=""
  item=""
  target_name=""
  target_value=""
  result_name=""
  warn_file="warn.txt"
  change_log="change.txt"

  [[ -n "$GEN_FILE" ]] || {
    echo "No -o setting, set bios.ini as default output ini file"
    GEN_FILE="bios.ini"
  }

  cat /dev/null > $GEN_FILE
  cat /dev/null > $warn_file
  cat /dev/null > $change_log
  echo "[BiosKnobs]" >> $GEN_FILE

  target_items=$(cat $TARGET_INI)
  for item in $target_items; do
    result=""
    target_name=""
    target_value=""
    result_name=""
    result_value=""

    [[ "$item" == *"="* ]] || continue
    target_name=$(echo $item | cut -d '=' -f 1)
    target_value=$(echo $item | cut -d '=' -f 2)
    result_name=$(cat $CURRENT_INI | grep "^${target_name}=")

    [[ -n "$result_name" ]] || {
      echo "item $target_name find in target $TARGET_INI but no in $CURRENT_INI"
      echo "item $target_name find in target $TARGET_INI but no in $CURRENT_INI" >> $warn_file
      continue
    }
    result_value=$(cat $CURRENT_INI | grep "^${target_name}=" | grep $target_value)
    if [[ -z "$result_value" ]]; then
      echo "Item |$result_name| -> |$item|"
      echo "Item |$result_name| -> |$item|" >> $change_log
    else
      continue
    fi
    echo $item >> $GEN_FILE
  done
  echo "$warn_file"
  echo "$GEN_FILE"
  echo "$change_log"
}

set_tbt_ini() {
  secure_exist=""
  secure_value=""

  [[ -d "$BIOS_DATA" ]] || {
    echo "$BIOS_DATA not exist, create it!"
    rm -rf $BIOS_DATA
    mkdir -p $BIOS_DATA
  }

  [[ -d "${BIOS_DATA}/bak" ]] || {
    echo "$BIOS_DATA/bak not exist, create it!"
    mkdir -p $BIOS_DATA/bak
  }

  secure_exist=$(cat $TARGET_INI | grep "^${SECURE_NAME}=" | head -n 1)
  if [[ -n "$secure_exist" ]]; then
    secure_value=$(cat $TARGET_INI | grep "^${SECURE_NAME}=" | head -n 1 | awk -F "${SECURE_NAME}=" '{print $2}' | awk -F '\"' '{print $1}')
    echo "back up old ini files: cp -rf ${BIOS_DATA}/*.ini ${BIOS_DATA}/bak"
    cp -rf ${BIOS_DATA}/*.ini ${BIOS_DATA}/bak

    echo "cp $TARGET_INI into ${BIOS_DATA} set_none/user/secure/dp.ini"
    cp -rf $TARGET_INI ${BIOS_DATA}/
    cp -rf $TARGET_INI ${BIOS_DATA}/set_none.ini
    cp -rf $TARGET_INI ${BIOS_DATA}/set_user.ini
    cp -rf $TARGET_INI ${BIOS_DATA}/set_secure.ini
    cp -rf $TARGET_INI ${BIOS_DATA}/set_dp.ini
    echo "sed -i s/${SECURE_NAME}=${secure_value}/${SECURE_NAME}=0x00/g $BIOS_DATA/set_none.ini"
    sed -i s/${SECURE_NAME}=${secure_value}/${SECURE_NAME}=0x00/g $BIOS_DATA/set_none.ini
    sed -i s/${SECURE_NAME}=${secure_value}/${SECURE_NAME}=0x01/g $BIOS_DATA/set_user.ini
    sed -i s/${SECURE_NAME}=${secure_value}/${SECURE_NAME}=0x02/g $BIOS_DATA/set_secure.ini
    sed -i s/${SECURE_NAME}=${secure_value}/${SECURE_NAME}=0x03/g $BIOS_DATA/set_dp.ini
  else
    echo "cp $TARGET_INI into ${BIOS_DATA} set_none/user/secure/dp.ini"
    cp -rf $TARGET_INI ${BIOS_DATA}/
    cp -rf $TARGET_INI ${BIOS_DATA}/set_none.ini
    cp -rf $TARGET_INI ${BIOS_DATA}/set_user.ini
    cp -rf $TARGET_INI ${BIOS_DATA}/set_secure.ini
    cp -rf $TARGET_INI ${BIOS_DATA}/set_dp.ini
    echo "No $SECURE_NAME in $TARGET_INI file! Create $SECURE_NAME=0x00/1/2/3!"
    echo "${SECURE_NAME}=0x00" >> $BIOS_DATA/set_none.ini
    echo "${SECURE_NAME}=0x01" >> $BIOS_DATA/set_user.ini
    echo "${SECURE_NAME}=0x02" >> $BIOS_DATA/set_secure.ini
    echo "${SECURE_NAME}=0x03" >> $BIOS_DATA/set_dp.ini
  fi
}

while getopts :f:c:t:o:s:h arg
do
  case $arg in
    f)
      SOUREC_FILE=$OPTARG
      [[ -e "$SOUREC_FILE" ]] || {
        echo "No origin file:$SOUREC_FILE exist"
        usage
      }
      ;;
    c)
      CURRENT_INI=$OPTARG
      [[ -e "$CURRENT_INI" ]] || {
        echo "No current ini file:$CURRENT_INI exist"
        usage
      }
      ;;
    t)
      TARGET_INI=$OPTARG
      [[ -e "$TARGET_INI" ]] || {
        echo "No target ini file:$TARGET_INI exist"
        usage
      }
      if [[ -z "$CURRENT_INI" ]]; then
        echo "No current ini:$CURRENT_INI"
        usage
      fi
      ;;
    s)
      TARGET_INI=$OPTARG
      [[ -e "$TARGET_INI" ]] || {
        echo "No target ini file:$TARGET_INI exist"
        usage
      }
      set_tbt_ini
      ;;
    o)
      GEN_FILE=$OPTARG
      ;;
    h)
      usage
      ;;
    :)
      usage
      ;;
  esac
done

[[ -n "$CURRENT_INI" ]] && [[ -n "$TARGET_INI" ]] && compare_ini
[[ -z "$SOUREC_FILE" ]] || generate_ini
