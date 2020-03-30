#!/bin/bash

# crontab -e
# 01 09 * * * /home/fedora29/tbt_driver_cases/update_intel-next.sh
# echo otc_intel_next_linux PATH > /root/path
log_path="/root/update_intel-next.log"
path_file="/root/path"
code_path=""
code_paths=""
time=$(date +%Y-%m-%d_%H:%M)
script_path=$(pwd)
default_path="/root/otc_intel_next-linux"
result=""

usage() {
  cat <<__EOF
	    usage: ./${0##*/} [NA][-c][-h]
  NA  No parameter, it will update otc_intel_next-linux once
  -c  set up auto run environment in Clear Linux
  -h  show This
    set intel-next code path into $path_file
    crontab -e
    30 08 * * * $script_path/update_intel-next.sh //it will be executed 08:30 every day.
__EOF
}

set_crond()
{
  local crond_service="/etc/systemd/system/crond.service"

  echo "[Service]" > $crond_service
  echo "Type=simple" >> $crond_service
  echo "ExecStart=/usr/bin/crond -n" >> $crond_service
  echo "[Install]" >> $crond_service
  echo "WantedBy=multi-user.target graphical.target" >> $crond_service

  sleep 1

  systemctl daemon-reload
  systemctl enable crond
  systemctl start crond

  echo "systemctl status crond"
  systemctl status crond
  echo "crond service is done:$crond_service"
}

update_intel_next()
{
script_path=$(pwd)
if [[ -e "$path_file" ]]; then
  code_paths=$(cat $path_file)
else
  echo "set intel-next code path into $path_file"
  echo "set $default_path as default in code_paths"
  code_paths="$default_path"
fi

for code_path in $code_paths; do
  if [[ -d "$code_path" ]]; then
    cd $code_path || return 1
  else
    echo "There was no directory: $code_path"
    echo "$time: there was no directory: $code_path" >> $log_path
    return 1
  fi
  git fetch origin -f
  result="$?"
  echo "$time: $code_path git fetch origin result:$result"
  echo "$time: $code_path git fetch origin result:$result" >> $log_path
done
}

while getopts ch arg
do
  case $arg in
    c)
      set_crond
      exit 0
      ;;
    h)
      usage && exit 0
      ;;
    *)
      ;;
  esac
done

update_intel_next
