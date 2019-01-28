#!/bin/bash

LOG_PATH="/root/result"

bounce_usb3="$LOG_PATH/iommu_b.txt"
nobounce_usb3="$LOG_PATH/iommu_nb.txt"
nbs_usb3="$LOG_PATH/iommu_nbs.txt"
read_file="read.csv"
write_file="write.csv"
num=0
usb3_infos=$(cat $bounce_usb3 | awk -F 'sent' '{print $2}' | awk -F 'MB' '{print $1}')

usb3=""
usb3_info=""

rb_value=""
rnb_value=""
rnbs_value=""

wb_value=""
wnb_value=""
wnbs_value=""

rb_total=0
rnb_total=0
rnbs_total=0

wb_total=0
wnb_total=0
wnbs_total=0

rnb_gap=""
rb_gap=""
rnb_gap_rate=""
rb_gap_rate=""

wb_gap=""
wnb_gap=""
wnb_gap_rate==""
rb_gap_rate=""

echo "usb3_size,           nobounce,     nobounce_strict,     bounce"
echo "usb3_size,           nobounce,     nobounce_strict,     bounce" > $LOG_PATH/$read_file
echo "usb3_size,           nobounce,     nobounce_strict,     bounce" > $LOG_PATH/$write_file

for usb3 in ${usb3_infos}; do
	num=$((num+1))
	read_result=""
	block="${usb3}k*1024"
	usb3_info=" $usb3 MB"
	rb_value=$(cat $bounce_usb3 | grep "$usb3_info" | awk -F 'read ' '{print $2}' | awk -F ' MB' '{print $1}')
	rnb_value=$(cat $nobounce_usb3 | grep "$usb3_info" | awk -F 'read ' '{print $2}' | awk -F ' MB' '{print $1}')
	rnbs_value=$(cat $nbs_usb3 | grep "$usb3_info" | awk -F 'read ' '{print $2}' | awk -F ' MB' '{print $1}')
	read_result=$(printf "%-13s  read,%-10s, %-10s, %16s" "$block" "$rnb_value" "$rnbs_value" "$rb_value")
	rb_total=$(printf "%.2f" $(echo "scale=2;$rb_total + $rb_value" | bc))
	rnb_total=$(printf "%.2f" $(echo "scale=2;$rnb_total + $rnb_value" | bc))
	rnbs_total=$(printf "%.2f" $(echo "scale=2;$rnbs_total + $rnbs_value" | bc))
	echo "$read_result"
	echo "$read_result" >> $LOG_PATH/$read_file

	write_result=""
	wb_value=$(cat $bounce_usb3 | grep "$usb3_info" | awk -F 'write ' '{print $2}' | awk -F ' MB' '{print $1}')
	wnb_value=$(cat $nobounce_usb3 | grep "$usb3_info" | awk -F 'write ' '{print $2}' | awk -F ' MB' '{print $1}')
	wnbs_value=$(cat $nbs_usb3 | grep "$usb3_info" | awk -F 'write ' '{print $2}' | awk -F ' MB' '{print $1}')
	write_result=$(printf "%-13s write,%-10s, %-10s, %16s" "$block" "$wnb_value" "$wnbs_value" "$wb_value")
	wb_total=$(printf "%.2f" $(echo "scale=2;$wb_total + $wb_value" | bc))
	wnb_total=$(printf "%.2f" $(echo "scale=2;$wnb_total + $wnb_value" | bc))
	wnbs_total=$(printf "%.2f" $(echo "scale=2;$wnbs_total + $wnbs_value" | bc))
	echo "$write_result"
	echo "$write_result" >> $LOG_PATH/$write_file

done
	echo "sample num:$num"
	rb_total=$(printf "%.3f" $(echo "scale=3;$rb_total/$num" | bc))
	rnb_total=$(printf "%.3f" $(echo "scale=3;$rnb_total/$num" | bc))
	rnbs_total=$(printf "%.3f" $(echo "scale=3;$rnbs_total/$num" | bc))

	rb_gap=$(printf "%.3f" $(echo "scale=3;$rb_total - $rnbs_total" | bc))
	rb_gap_rate=$(printf "%.4f" $(echo "scale=4;$rb_gap/$rnbs_total" | bc))
	
	rnb_gap=$(printf "%.3f" $(echo "scale=3;$rnbs_total - $rnb_total" | bc))
	rnb_gap_rate=$(printf "%.4f" $(echo "scale=4;$rnb_gap/$rnb_total" | bc))

	echo "usb3 read nobounce average MB/s:$rnb_total, nobounce strict(delay iotlb flush disabled) average MB/s:$rnbs_total, bounce average:$rb_total"
	echo "read nobounce with strict gap rate:$rnb_gap_rate,   nobounce strict and bounce gap rate:$rb_gap_rate"

	wb_total=$(printf "%.3f" $(echo "scale=3;$wb_total/$num" | bc))
	wnb_total=$(printf "%.3f" $(echo "scale=3;$wnb_total/$num" | bc))
	wnbs_total=$(printf "%.3f" $(echo "scale=3;$wnbs_total/$num" | bc))

	wb_gap=$(printf "%.3f" $(echo "scale=3;$wb_total - $wnbs_total" | bc))
	wb_gap_rate=$(printf "%.4f" $(echo "scale=4;$wb_gap/$wnbs_total" | bc))

	wnb_gap=$(printf "%.3f" $(echo "scale=3;$wnbs_total - $wnb_total" | bc))
	wnb_gap_rate=$(printf "%.4f" $(echo "scale=4;$wnb_gap/$wnb_total" | bc))

	echo "usb3 write nobounce average MB/s:$wnb_total, nobounce strict(delay iotlb flush disabled) average MB/s:$wnbs_total, bounce average:$wb_total"
	echo "write nobounce with strict gap rate:$wnb_gap_rate,   nobounce strict and bounce gap rate:$wb_gap_rate"
