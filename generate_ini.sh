#!/bin/bash

SOUREC_FILE=""
GEN_FILE=""
NAMES=""

usage() {
  cat <<__EOF
  usage: ./${0##*/} [-f XML_FILE][-c CURRENT_INI][-t TARGET_INI]
    -f XML_FILE: will generate full bios item ini
    -c CURRENT_INI -t TARGET_INI: will compare both and generate delta target ini
__EOF
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

  [[ -n "$GEN_FILE" ]] || {
    echo "No -o setting, set bios.ini as default output ini file"
    GEN_FILE="bios.ini"
  }
  cat /dev/null > $GEN_FILE

  target_items=$(cat $TARGET_INI)
  for item in $target_items; do
    result=""
    target_name=""
    target_value=""
    result_name=""
    result_value=""

    target_name=$(echo $item | cut -d '=' -f 1)
    target_value=$(echo $item | cut -d '=' -f 2)
    result_name=$(cat $CURRENT_INI | grep $target_name)

    [[ -n "$result_name" ]] || {
      echo "item $target_name find in target $TARGET_INI but no in $CURRENT_INI"
      continue
    }
    result_value=$(cat $CURRENT_INI | grep $target_name | grep $target_value)
    if [[ -z "$result_value" ]]; then
      echo "Item:$result_name will change to $target_value"
    else
      continue
    fi
    echo $item >> $GEN_FILE

  done
}


while getopts :f:c:t:o:h arg
do
  case $arg in
    f)
      SOUREC_FILE=$OPTARG
      [[ -e "$SOUREC_FILE" ]] || {
        echo "No origin file:$SOUREC_FILE exist"
        usage
        exit 2
      }
      generate_ini
      ;;
    c)
      CURRENT_INI=$OPTARG
      [[ -e "$CURRENT_INI" ]] || {
        echo "No current ini file:$CURRENT_INI exist"
        usage
        exit 2
      }
      ;;
    t)
      TARGET_INI=$OPTARG
      [[ -e "$TARGET_INI" ]] || {
        echo "No target ini file:$TARGET_INI exist"
        usage
        exit 2
      }
      if [[ -z "$CURRENT_INI" ]]; then
        echo "No current ini:$CURRENT_INI"
        usage
        exit 2
      else
        compare_ini
      fi
      ;;
     o)
       GEN_FILE=$OPTARG
       ;;
     h)
       usage
       exit 2
       ;;
     :)
       usage
       exit 2
       ;;
  esac
done

[[ -z "$SOUREC_FILE" ]] && [[ -z "$CURRENT_INI" ]] && usage
