#!/bin/bash

SOUREC_FILE=$1
GEN_FILE=$2
NAMES=""

[[ -n "$GEN_FILE" ]] || {
  echo "No Parm2, set bios.ini as default"
  GEN_FILE="bios.ini"
}

usage() {
  cat <<__EOF
  usage: ./${0##*/} ORIGIN_FILE TARGET_FILE
    ORIGIN_FILE: usually it's default setting xml file
    TARGET_FILE: usually it's our target worked bios xml file
    Will generate bios_set.nsh
__EOF
}

[[ -e "$SOUREC_FILE" ]] || {
  echo "No origin file:$SOUREC_FILE exist"
  usage
  exit 2
}

generate_ini() {
  name=""
  NAMES=$(cat $SOUREC_FILE | grep " name=\"" | awk -F "name=" '{print $2}' | awk -F '\"' '{print $2}')
  value=""

  cat /dev/null > $GEN_FILE
  for name in ${NAMES}; do
    value=""
    value=$(cat "$SOUREC_FILE" | grep "name=\"$name\"" | awk -F "CurrentVal=" '{print $2}' | awk -F '\"' '{print $2}' | tail -n 1)
    [[ -n "$value" ]] || echo "Warning!!! $name in $TARGET_FILE is null"
    echo "${name}=$value" >> $GEN_FILE
  done

  echo "Done. Generated $GEN_FILE"
}

generate_ini
