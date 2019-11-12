#!/bin/bash
log_path="/root/update_intel-next.log"
path_file="/root/path"
code_path=""
time=$(date +%Y-%m-%d_%H:%M)

code_path=$(cat $path_file)
[[ -n "$code_path" ]] || code_path="/root/otc_intel_next-linux"

cd $code_path
git fetch origin
echo "$time: $code_path, 'git fetch origin' result:$?" >> $code_path
