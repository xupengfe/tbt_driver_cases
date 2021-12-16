#!/bin/bash

CASE_LIST_FILE=$1
P_NUM=$2

DDT_PATH="/home/os.linux.validation.ltp-ddt-for-ia/"
SPEC_PATH="${DDT_PATH}/runtest/spec"
CASE_PATH="${DDT_PATH}/runtest/ddt_intel/upstream"

usage() {
  cat <<__EOF
  usage: ./${0##*/}  "CASE_LIST_FILE" "P?"
  -h  show This
__EOF
  exit 1
}

check_parm()
{
  [[ -e "$CASE_LIST_FILE" ]] || {
    echo "$CASE_LIST_FILE does not exist"
    usage
  }

  [[ "$P_NUM" == "P"* ]] || {
    echo "2nd parm is not started with P, like P5"
    usage
  }
}

change_p_num()
{
  local cases=""
  local case=""
  local c_content=""
  local p_content=""
  local p_num=""

  cases=$(cat $CASE_LIST_FILE 2>/dev/null)
  [[ -z "$cases" ]] && {
    echo "$CASE_LIST_FILE is null"
    usage
  }

  for case in $cases; do
    c_content=""
    p_content=""
    p_num=""

    c_content=$(grep -r "$case" ${CASE_PATH}/*)
    p_content=$(cat "$SPEC_PATH/$case.json" | grep "\"priority\":" | grep "P")
    if [[ -z "$c_content" ]]; then
      if [[ -z "p_content" ]]; then
        echo "${SPEC_PATH}/${case}.json does not exist as expected"
        continue
      else
        echo "${SPEC_PATH}/${case}.json should not exist, no DDT case for it"
        continue
      fi
    else
      if [[ -z "p_content" ]]; then
        echo "${SPEC_PATH}/${case}.json does not exist, need to add this json!"
        continue
      fi
    fi

    p_num=$(echo $p_content | awk -F "\"" '{print $(NF-1)}')
    echo "${SPEC_PATH}/${case}.json $p_num -> $P_NUM"
    sed -i s/$p_num\"\,/$P_NUM\"\,/g "${SPEC_PATH}/${case}.json"
  done
}

check_parm
change_p_num
