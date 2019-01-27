#!/bin/bash

declare -A usb3_dict
LOG_PATH="/opt/logs/5.0-rc1"

bounce_usb3="$LOG_PATH/tbt_iommu_bounce_usb3.txt"
nobounce_usb3="$LOG_PATH/tbt_iommu_nobounce_usb3.txt"

IFS=","

#declare -a usb3_infos="'1.00 MB' '8.00 MB' '64.00 MB' '256.00 MB' '1.00 GB'"
usb3_infos=("1.00 MB","8.00 MB","64.00 MB","256.00 MB","1.00 GB")
usb3_info=""
usb3_dict=(["1.00 MB"]="1k*1024" ["8.00 MB"]="8k*1024" ["64.00 MB"]="64k*1024" ["256.00 MB"]="256k*1024" ["1.00 GB"]="1024k*1024")
rb_value=""
rnb_value=""
read_gap=""
read_gap_rate==""
wb_value=""
wnb_value=""
write_gap=""
write_gap_rate==""
read_result=""
write_result=""
rb_total=0
rnb_total=0
wb_total=0
wnb_total=0
rb_gap=""
rb_gap_rate=""

echo "usb3_size:      usb3_nobounce,     usb3_bounce,    gap_rate"

for usb3_info in ${usb3_infos}; do
	read_result=""
	rb_value=$(cat $bounce_usb3 | grep "$usb3_info" | awk -F 'read ' '{print $2}' | awk -F ' MB' '{print $1}')
	rnb_value=$(cat $nobounce_usb3 | grep "$usb3_info" | awk -F 'read ' '{print $2}' | awk -F ' MB' '{print $1}')
	read_gap=$(printf "%.2f" $(echo "scale=2;$rnb_value - $rb_value" | bc))
	read_gap_rate=$(printf "%.4f" $(echo "scale=4;$read_gap/$rnb_value" | bc))
	read_result=$(printf "%-10s  read:%-10s, %-10s, %16s" "${usb3_dict[$usb3_info]}" "$rnb_value" "$rb_value" "$read_gap_rate")
	rb_total=$(printf "%.2f" $(echo "scale=2;$rb_total + $rb_value" | bc))
	rnb_total=$(printf "%.2f" $(echo "scale=2;$rnb_total + $rnb_value" | bc))
	echo "$read_result"


	write_result=""
	wb_value=$(cat $bounce_usb3 | grep "$usb3_info" | awk -F 'write ' '{print $2}' | awk -F ' MB' '{print $1}')
	wnb_value=$(cat $nobounce_usb3 | grep "$usb3_info" | awk -F 'write ' '{print $2}' | awk -F ' MB' '{print $1}')
	write_gap=$(printf "%.2f" $(echo "scale=2;$wnb_value - $wb_value" | bc))
	write_gap_rate=$(printf "%.4f" $(echo "scale=4;$write_gap/$wnb_value" | bc))
	write_result=$(printf "%-10s write:%-10s, %-10s, %16s" "${usb3_dict[$usb3_info]}" "$wnb_value" "$wb_value" "$write_gap_rate")
	wb_total=$(printf "%.2f" $(echo "scale=2;$wb_total + $wb_value" | bc))
	wnb_total=$(printf "%.2f" $(echo "scale=2;$wnb_total + $wnb_value" | bc))
	echo "$write_result"
done
	rb_total=$(printf "%.2f" $(echo "scale=2;$rb_total/5" | bc))
	rnb_total=$(printf "%.2f" $(echo "scale=2;$rnb_total/5" | bc))

	rb_gap=$(printf "%.2f" $(echo "scale=2;$rnb_total - $rb_total" | bc))
	rb_gap_rate=$(printf "%.4f" $(echo "scale=4;$rb_gap/$rnb_total" | bc))
	echo "usb3 read nobounce average MB/s:$rnb_total,  bounce average MB/s:$rb_total, gap rate:$rb_gap_rate"

	wb_total=$(printf "%.2f" $(echo "scale=2;$wb_total/5" | bc))
	wnb_total=$(printf "%.2f" $(echo "scale=2;$wnb_total/5" | bc))

	wb_gap=$(printf "%.2f" $(echo "scale=2;$wnb_total - $wb_total" | bc))
	wb_gap_rate=$(printf "%.4f" $(echo "scale=4;$wb_gap/$wnb_total" | bc))

	echo "usb3 write nobounce average MB/s:$wnb_total,  bounce average MB/s:$wb_total, gap rate:$wb_gap_rate"
