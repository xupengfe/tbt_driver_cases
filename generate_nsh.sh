#!/bin/bash

ORIGIN_FILE=$1
TARGET_FILE=$2
NAMES=""
GEN_FILE="bios_set.nsh"

usage() {
  cat <<__EOF
  usage: ./${0##*/} ORIGIN_FILE TARGET_FILE
    ORIGIN_FILE: usually it's default setting xml file
    TARGET_FILE: usually it's our target worked bios xml file
      Will generate bios_set.nsh
__EOF
}

[[ -e "$ORIGIN_FILE" ]] || {
  echo "No origin file:$ORIGIN_FILE exist"
  usage
  exit 2
}

[[ -e "$TARGET_FILE" ]] || {
  echo "No origin file:$TARGET_FILE exist"
  usage
  exit 2
}

generate_nsh() {
  name=""
  NAMES=$(diff $ORIGIN_FILE $TARGET_FILE | grep "^>" | grep "name=" | awk -F "name=" '{print $2}' | awk -F '\"' '{print $2}')
  value=""

  echo "echo -off" > $GEN_FILE
  echo >> $GEN_FILE
  echo "fs0:" >> $GEN_FILE
  for name in ${NAMES}; do
    value=""
    value=$(cat "$TARGET_FILE" | grep "name=\"$name\"" | awk -F "CurrentVal=" '{print $2}' | awk -F '\"' '{print $2}')
    [[ -n "$value" ]] || echo "Warning!!! $name in $TARGET_FILE is null"
    echo "XmlCliKnobs.efi AP -s \"${name}=$value\"" >> $GEN_FILE
  done

  cat $GEN_FILE
}

generate_nsh
