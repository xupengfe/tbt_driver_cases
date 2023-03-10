#!/bin/sh
#
# Copyright (C) 2018, Intel Corporation
# Author: Westerberg, Mika <mika.westerberg@intel.com>
# https://gitlab.devtools.intel.com/mwesterb/lpsstest/-/blob/master/device-power.sh
# device-power.sh -s
#

export PATH=/bin:/usr/bin

gen_acpi_devices="INTL9C60"
byt_acpi_devices="80860F09 80860F0A 80860F0E 80860F14 80860F41 INT33B2 INT33BB"
bsw_acpi_devices="80862288 8086228A 8086228E 808622C1"
lpt_acpi_devices="INT33C0 INT33C1 INT33C2 INT33C3 INT33C4 INT33C5 INT33C6"
wpt_acpi_devices="INT3430 INT3431 INT3432 INT3433 INT3434 INT3435 INT3436"

all_acpi_devices="$gen_acpi_devices"
all_acpi_devices="$all_acpi_devices $byt_acpi_devices $bsw_acpi_devices"
all_acpi_devices="$all_acpi_devices $lpt_acpi_devices $wpt_acpi_devices"

all_pmc_pci_devices="0f1c 229c"

show_status() {
	local dev="$1"
	local devid="$2"
	local status="$3"
	local real_status="$4"
	local rpm="$5"
	local name="$6"

	[ -n "$dev" ] && {
		printf "\033[1;37m%s\033[m " "$dev"
	}

	[ -n "$devid" ] && {
		printf "%s " "$devid"
	}

	[ -n "$status" ] && {
		case $status in
		D3|D3cold|D3hot)
			printf "Status: [\033[1;32m%6s\033[m] " "$status"
			;;
		N/A)
			printf "Status: [\033[1;30m%6s\033[m] " "$status"
			;;
		*)
			printf "Status: [\033[1;31m%6s\033[m] " "$status"
			;;
		esac
	}

	[ -n "$real_status" ] && {
		case $real_status in
		D3|D3cold|D3hot)
			printf "Real status: [\033[1;32m%6s\033[m] " "$real_status"
			;;
		N/A)
			printf "Real status: [\033[1;30m%6s\033[m] " "$real_status"
			;;
		*)
			printf "Real status: [\033[1;31m%6s\033[m] " "$real_status"
			;;
		esac
	}

	[ -n "$rpm" ] && {
		case $rpm in
		suspended)
			printf "Runtime PM: [\033[1;32m%9s\033[m]" "$rpm"
			;;
		active)
			printf "Runtime PM: [\033[1;31m%9s\033[m]" "$rpm"
			;;
		*)
			printf "Runtime PM: [\033[1;30m%9s\033[m]" "$rpm"
			;;
		esac
	}

	[ -n "$status" -o -n "$rpm" ] && {
		printf "\n"
	}

	[ -n "$name" ] && {
		printf "    %s\n" "$name"
	}
}

show_lpss_status_pmc() {
	local state_file=/sys/kernel/debug/pmc_atom/pss_state
	if [ -f $state_file ]; then
		local status=$(grep LPSS $state_file | sed -rn 's/^Island.*State: (Off|On)/\1/p')
		case $status in
		Off)
			printf "Actual LPSS state [\033[1;32m$status\033[m]\n"
			;;
		*)
			printf "Actual LPSS state [\033[1;31m$status\033[m]\n"
			;;
		esac
	else
		echo "The actual LPSS status cannot be read from debugfs."
		echo ""
		echo "If you want that you need to enable CONFIG_PMC_ATOM from your"
		echo "kernel .config and mount debugfs before running this script:"
		echo "  # mount -t debugfs none /sys/kernel/debug"
		echo ""
	fi
}

show_pci_devices() {
	echo "All PCI devices"

	lspci -vv 2>/dev/null | awk '
		/^[0-9]/ {
			name = $0
			sub($1 " *", "", name)
			bdf = $1
			status = ""
		}

		name != "" && /Status: D[0-3]/ { status = $2 }

		/^$/ {
			if (status)
				print bdf " " status " " name
			else
				print bdf " D0 " name

			name = ""
		}' |
	while read bdf status name; do
		local rpm=$(cat "/sys/bus/pci/devices/0000:$bdf/power/runtime_status")
		local vendor=$(cat "/sys/bus/pci/devices/0000:$bdf/vendor" | sed s/^0x//)
		local device=$(cat "/sys/bus/pci/devices/0000:$bdf/device" | sed s/^0x//)
		local vdid="$vendor:$device"

		show_status "$bdf" "$vdid" "$status" "" "$rpm" "$name"
	done

	echo
}

show_pci_devices_software() {
	echo "All PCI devices (software state)"

	for dev in /sys/bus/pci/devices/0000:*; do
		local bdf=$(basename $dev)
		local rpm=$(cat "/sys/bus/pci/devices/$bdf/power/runtime_status")
		local vendor=$(cat "/sys/bus/pci/devices/$bdf/vendor" | sed s/^0x//)
		local device=$(cat "/sys/bus/pci/devices/$bdf/device" | sed s/^0x//)
		local vdid="$vendor:$device"
		local acpi_state=$(cat $dev/firmware_node/power_state 2>/dev/null)
		local acpi_real_state=$(cat $dev/firmware_node/real_power_state 2>/dev/null)
		[ -z "$acpi_state" ] && acpi_state="N/A"
		[ -z "$acpi_real_state" ] && acpi_real_state="N/A"
		show_status "$bdf" "$vdid" "$acpi_state" "$acpi_real_state" "$rpm" ""
	done

	echo
}

show_acpi_devices() {
	local start=

	for hid in $all_acpi_devices; do
		local path="/sys/bus/platform/devices/$hid:*"
		for dev in $path; do
			[ -d "$dev" ] || continue

			if [ -z "$start" ]; then
				echo "LPSS ACPI devices"
				start=1
			fi

			local name=$(cat $dev/firmware_node/path 2>/dev/null)
			local status=$(cat $dev/firmware_node/power_state 2>/dev/null)
			local real_status=$(cat $dev/firmware_node/real_power_state 2>/dev/null)
			local rpm=$(cat $dev/power/runtime_status)

			# Expect D0 if status is not explicitly available
			[ -z "$status" ] && status="D0"
			[ -z "$real_status" ] && real_status="N/A"

			show_status "$dev" "" "$status" "$real_status" "$rpm" "$name"
		done
	done

	[ -n "$start" ] && echo
}

usage() {
	echo "Usage: $0 [-h|--help] [-s|--software]"
	echo
	echo "Options:"
	echo "  -h|--help	Show this help test"
	echo "  -s|--software	Show only software PM state of PCI devices"
	echo
	echo "When listing PCI devices that can go to D3cold, running"
	echo "the script without '--software' option may trigger runtime"
	echo "resume of the device and thus show it in D0 instead of D3cold."
	echo

	exit
}

software=0
if [ $# -ge 1 ]; then
	case "$1" in
	-s|--software)
		software=1
		;;
	*)
		usage
		;;
	esac
fi

if [ "$software" = "1" ]; then
	show_pci_devices_software
else
	show_pci_devices
fi

show_acpi_devices

for pmc in $all_pmc_pci_devices; do
	name=$(lspci -d "8086:$pmc" 2>/dev/null)
	echo "name:$name"
	if [ -n "$name" ]; then
		show_lpss_status_pmc
	fi
done
