#!/bin/bash

# crontab -e
# 01 09 * * * /home/fedora29/tbt_driver_cases/update_intel-next.sh
# echo otc_intel_next_linux PATH > /root/path
log_path="/root/update_intel-next.log"
path_file="/root/path"
code_path=""
time=$(date +%Y-%m-%d_%H:%M)
script_path=$(pwd)
default_path="/root/otc_intel_next-linux"
result=""

usage() {
  cat <<__EOF
	    usage: ./${0##*/} [-h]
  -h  show This
  set intel-next code path into $path_file
  crontab -e
  01 09 * * * $script_path/update_intel-next.sh
__EOF
}

update_intel_next()
{
script_path=$(pwd)
if [[ -e "$path_file" ]]; then
  code_path=$(cat $path_file | head -n 1)
else
  echo "set intel-next code path into $path_file"
  echo "set $default_path as default in code_path"
fi

[[ -n "$code_path" ]] || code_path="$default_path"

if [[ -d "$code_path" ]]; then
  cd $code_path
else
  echo "There was no directory: $code_path"
  echo "$time: there was no directory: $code_path" >> $log_path
  exit 1
fi
git fetch origin
result="$?"
echo "$time: $code_path git fetch origin result:$?"
echo "$time: $code_path git fetch origin result:$?" >> $log_path
}

while getopts h arg
do
  case $arg in
    h)
      usage && exit 0
      ;;
    *)
      ;;
  esac
done

update_intel_next
