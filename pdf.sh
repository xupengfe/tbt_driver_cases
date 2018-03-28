#!/bin/bash
file_name=""
date=$(date +"%Y%m%d_%H%M")
file_name=$1
file=""
if [[ -z "$file_name" ]]; then
  enscript tbt_cases.sh -o - | ps2pdf - tbt_cases_$date.pdf
else
  file=$(echo $file_name | cut -d '.' -f 1)
  enscript $file_name -o - | ps2pdf - "$file"_"$date".pdf
fi
