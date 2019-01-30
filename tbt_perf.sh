#!/bin/bash

log_path=$1

date_file="perf_date.txt"
bak_file="perf_date.txt_bak"
[[ -e "$date_file" ]] && mv $date_file $bak_file
date
date > $date_file
if [[ -z $log_path ]]; then
  echo "./runtests.sh -p cfl-h-rvp -P cfl-h-rvp -f ddt_intel/tbt_perf_tests -o /opt/logs/tbt_perf -c" >> $date_file
  ./runtests.sh -p cfl-h-rvp -P cfl-h-rvp -f ddt_intel/tbt_perf_tests -o /opt/logs/tbt_perf -c
else
  echo "./runtests.sh -p cfl-h-rvp -P cfl-h-rvp -f ddt_intel/tbt_perf_tests -o $date_file -c" >> $date_file
  ./runtests.sh -p cfl-h-rvp -P cfl-h-rvp -f ddt_intel/tbt_perf_tests -o $date_file -c
fi
date >> perf_date.txt
date
