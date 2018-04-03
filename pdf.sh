#!/bin/bash
file_name=""
date=$(date +"%Y%m%d_%H%M")
file_name=$1
file=""
bak="bak"
old=""
num=""
enscript=""

enscript=$(dpkg -l | grep enscript)
[[ -z "$enscript" ]] && sudo apt install -y enscript

if [[ -z "$file_name" ]]; then
  [[ -e "$bak" ]] || mkdir "$bak"
  num=$(ls -l "$bak" |grep "^-"|wc -l)
  [[ num -le 3 ]] || {
    old=$(ls -1 "$bak" | head -n 1)
    rm -f "$bak"/"$old"
  }
  mv ./*.pdf "$bak"
  enscript tbt_cases.sh -o - | ps2pdf - tbt_cases_"$date".pdf
  sleep 1
  enscript tbt_cases.sh -o - | ps2pdf - tbt_cases_in_DDT.pdf
else
  file=$(echo "$file_name" | cut -d '.' -f 1)
  enscript "$file_name" -o - | ps2pdf - "$file"_"$date".pdf
fi
