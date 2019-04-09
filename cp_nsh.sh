#!/bin/bash

PATH=$1
NSH_FILE=$2
SECURE_NAME="SecurityMode"


usage() {
  cat <<__EOF
  usage: ./${0##*/} USB_PATH NSH_FILE(optional)
    USB_PATH: mount USB path
    NSH_FILE: optional, if not filled will choose bios_set.nsh as default
      Will generate set_none.nsh, set_user.nsh, set_secure.nsh and set_dp.nsh in USB path
__EOF
}

[[ -d "$PATH" ]] || {
  echo "No mount USB folder:$PATH exist"
  usage
  exit 2
}

[[ -e "$NSH_FILE" ]] || {
  echo "no file $NSH_FILE exist, set bios_set.nsh as default"
  NSH_FILE="bios_set.nsh"
}

[[ -e "$NSH_FILE" ]] || {
  echo "$NSH_FILE was still not exit, will exit!"
  exit 2
}

cp_nsh() {
  secure_exist=""
  secure_value=""

  secure_exist=$(cat $NSH_FILE | grep $SECURE_NAME)
  if [[ -n "$secure_exist" ]]; then
    secure_value=$(cat $NSH_FILE | grep $SECURE_NAME | awk -F "${SECURE_NAME}=" '{print $2}' | awk -F '\"' '{print $1}')
    echo "sed s/${SECURE_NAME}=${secure_value}/${SECURE_NAME}=0x00/g $NSH_FILE > ${PATH}/set_none.nsh"
    sed s/${SECURE_NAME}=${secure_value}/${SECURE_NAME}=0x00/g $NSH_FILE > ${PATH}/set_none.nsh
    sed s/${SECURE_NAME}=${secure_value}/${SECURE_NAME}=0x01/g $NSH_FILE > ${PATH}/set_user.nsh
    sed s/${SECURE_NAME}=${secure_value}/${SECURE_NAME}=0x02/g $NSH_FILE > ${PATH}/set_secure.nsh
    sed s/${SECURE_NAME}=${secure_value}/${SECURE_NAME}=0x03/g $NSH_FILE > ${PATH}/set_dp.nsh
  else
    echo "set XmlCliKnobs.efi AP -s \"SecurityMode=0x00\" in end of ${PATH}/set_none.nsh"
    echo "XmlCliKnobs.efi AP -s \"SecurityMode=0x00\"" >> ${PATH}/set_none.nsh
    echo "XmlCliKnobs.efi AP -s \"SecurityMode=0x01\"" >> ${PATH}/set_user.nsh
    echo "XmlCliKnobs.efi AP -s \"SecurityMode=0x02\"" >> ${PATH}/set_secure.nsh
    echo "XmlCliKnobs.efi AP -s \"SecurityMode=0x03\"" >> ${PATH}/set_dp.nsh
  fi
}

cp_nsh
