#!/bin/bash
file_name=""
date=$(date +"%Y%m%d_%H%M")
file_name=$1
file=""
bak="bak"

if [[ -z "$file_name" ]]; then
  [[ -e "$bak" ]] || mkdir "$bak"
  mv ./*.pdf "$bak"
  enscript tbt_cases.sh -o - | ps2pdf - tbt_cases_"$date".pdf
  sleep 1
  enscript tbt_cases.sh -o - | ps2pdf - tbt_cases_in_DDT.pdf
else
  file=$(echo "$file_name" | cut -d '.' -f 1)
  enscript "$file_name" -o - | ps2pdf - "$file"_"$date".pdf
fi
