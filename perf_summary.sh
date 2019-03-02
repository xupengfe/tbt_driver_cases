#!/bin/bash

IOMMU_NB="iommu_nb"
IOMMU_NBS="iommu_nbs"
IOMMU_BOUNCE="iommu_bounce"
IOMMU="iommu"

verify_perf_result() {
  local nb=$1
  local nbs=$2
  local bounce=$3
  local tp=$4
  local infos=""
  local info=""
  local rb_value=""
  local rnb_value=""
  local rnbs_value=""
  local wb_value=""
  local wnb_value=""
  local wnbs_value=""
  local rb_total=0
  local rnb_total=0
  local rnbs_total=0
  local wb_total=0
  local wnb_total=0
  local wnbs_total=0
  local rnb_gap=""
  local rb_gap=""
  local rnb_gap_rate=""
  local rb_gap_rate=""
  local wb_gap=""
  local wnb_gap=""
  local wnb_gap_rate=""
  local rb_gap_rate=""
  local head=""
  local read_file="read_iommu_${tp}.CSV"
  local write_file="write_iommu_${tp}.CSV"
  local num=0
  local read_line=""
  local write_line=""
  local block=""
  local block_info=""
  local read="read"
  local mb="MB"
  local write="write"
  local result=""
  local size_info=""


  infos=$(cat $nb \
         | awk -F 'sent' '{print $2}' \
         | awk -F 'MB' '{print $1}')

  size_info=$(cat $nb | grep "size")

  echo $(uname -r) > $read_file
  echo $(uname -r) > $write_file
  head="${tp}->$size_info,            nobounce,    nobounce_strict,   bounce"
  echo $head >> $read_file
  echo $head >> $write_file

  for info in ${infos}; do
    num=$((num+1))
    block="${info}k*1024"
    block_info=" $info MB"
    rb_value=$(cat $bounce \
              | grep "$block_info" \
              | awk -F $read '{print $2}' \
              | awk -F $mb '{print $1}')
    rnb_value=$(cat $nb \
              | grep "$block_info" \
              | awk -F $read '{print $2}' \
              | awk -F $mb '{print $1}')
    rnbs_value=$(cat $nbs \
                | grep "$block_info" \
                | awk -F $read '{print $2}' \
                | awk -F $mb '{print $1}')
    read_line=""
    read_line=$(printf "%-13s  read,%-10s, %-9s, %14s" \
                "$block" "$rnb_value" "$rnbs_value" "$rb_value")
    rb_total=$(printf "%.2f" $(echo "scale=2;$rb_total + $rb_value" | bc))
    rnb_total=$(printf "%.2f" $(echo "scale=2;$rnb_total + $rnb_value" | bc))
    rnbs_total=$(printf "%.2f" $(echo "scale=2;$rnbs_total + $rnbs_value" | bc))
    echo "$read_line" >> $read_file

    wb_value=$(cat $bounce \
              | grep "$block_info" \
              | awk -F $write '{print $2}' \
              | awk -F $mb '{print $1}')
    wnb_value=$(cat $nb \
              | grep "$block_info" \
              | awk -F $write '{print $2}' \
              | awk -F $mb '{print $1}')
    wnbs_value=$(cat $nbs \
                | grep "$block_info" \
                | awk -F $write '{print $2}' \
                | awk -F $mb '{print $1}')
    write_line=""
    write_line=$(printf "%-13s write,%-10s, %-9s, %14s" \
                  "$block" "$wnb_value" "$wnbs_value" "$wb_value")
    wb_total=$(printf "%.2f" $(echo "scale=2;$wb_total + $wb_value" | bc))
    wnb_total=$(printf "%.2f" $(echo "scale=2;$wnb_total + $wnb_value" | bc))
    wnbs_total=$(printf "%.2f" $(echo "scale=2;$wnbs_total + $wnbs_value" | bc))
    echo "$write_line" >> $write_file
  done

  echo "sample num:$num"
  rb_total=$(printf "%.3f" $(echo "scale=3;$rb_total/$num" | bc))
  rnb_total=$(printf "%.3f" $(echo "scale=3;$rnb_total/$num" | bc))
  rnbs_total=$(printf "%.3f" $(echo "scale=3;$rnbs_total/$num" | bc))

  rb_gap=$(printf "%.3f" $(echo "scale=3;$rb_total - $rnbs_total" | bc))
  rb_gap_rate=$(printf "%.4f" $(echo "scale=4;$rb_gap/$rnbs_total" | bc))

  rnb_gap=$(printf "%.3f" $(echo "scale=3;$rnbs_total - $rnb_total" | bc))
  rnb_gap_rate=$(printf "%.4f" $(echo "scale=4;$rnb_gap/$rnb_total" | bc))

  echo "$tp read nobounce        average MB/s:$rnb_total" >> $read_file
  echo "$tp read nobounce strict average MB/s:$rnbs_total" >> $read_file
  echo "$tp read bounce          average MB/s:$rb_total" >> $read_file
  echo "$tp read nobounce with strict gap rate: $rnb_gap_rate" >> $read_file
  echo "$tp read nobounce strict and bounce gap:$rb_gap_rate" >> $read_file

  wb_total=$(printf "%.3f" $(echo "scale=3;$wb_total/$num" | bc))
  wnb_total=$(printf "%.3f" $(echo "scale=3;$wnb_total/$num" | bc))
  wnbs_total=$(printf "%.3f" $(echo "scale=3;$wnbs_total/$num" | bc))

  wb_gap=$(printf "%.3f" $(echo "scale=3;$wb_total - $wnbs_total" | bc))
  wb_gap_rate=$(printf "%.4f" $(echo "scale=4;$wb_gap/$wnbs_total" | bc))

  wnb_gap=$(printf "%.3f" $(echo "scale=3;$wnbs_total - $wnb_total" | bc))
  wnb_gap_rate=$(printf "%.4f" $(echo "scale=4;$wnb_gap/$wnb_total" | bc))

  echo "$tp write nobounce        average MB/s:$wnb_total" >> $write_file
  echo "$tp write nobounce strict average MB/s:$wnbs_total" >> $write_file
  echo "$tp write bounce          average MB/s:$wb_total" >> $write_file
  echo "$tp write nobounce with strict gap rate: $wnb_gap_rate" >> $write_file
  echo "$tp write nobounce strict and bounce gap:$wb_gap_rate" >> $write_file

  cat $read_file
  cat $write_file

  result=$(echo "$rnb_gap_rate <= 0 " | bc)
  [[ "$result" -eq 1 ]] || echo "rnb_gap_rate greater than 0:$rnb_gap_rate"

  result=$(echo "$rb_gap_rate <= 0 " | bc)
   [[ "$result" -eq 1 ]] || echo "rb_gap_rate greater than 0:$rb_gap_rate"

  result=$(echo "$wnb_gap_rate <= 0 " | bc)
  [[ "$result" -eq 1 ]] || echo "wnb_gap_rate greater than 0:$wnb_gap_rate"

  result=$(echo "$wb_gap_rate <= 0 " | bc)
  [[ "$result" -eq 1 ]] || echo "wb_gap_rate greater than 0:$wb_gap_rate"
}

main() {
  local tps="2.0 3.0 ssd"
  local tp=""
  local nb=""
  local nbs=""
  local bounce=""

  for tp in ${tps}; do
    nb="${IOMMU_NB}_${tp}.txt"
    nbs="${IOMMU_NBS}_${tp}.txt"
    bounce="${IOMMU_BOUNCE}_${tp}.txt"

    echo "tp:$tp"
    [[ -e "$nb" ]] || {
      echo "no $nb file, test 2 other $info"
      break
    }
    [[ -e "$nbs" ]] || {
      echo "no $nbs file, test 2 other $info"
      break
    }
    [[ -e "$bounce" ]] || {
      echo "no $bounce file, please enable iommu"
      break
    }

    verify_perf_result "$nb" "$nbs" "$bounce" "$tp"
  done
}

main
