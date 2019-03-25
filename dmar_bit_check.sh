#!/bin/bash
dmar=""
result=""

acpidump -f -o acpi.dump
acpixtract -f -a acpi.dump
iasl dmar.dat

dmar=$(cat dmar.dsl | grep "025h")
result=$(cat dmar.dsl | grep "025h" | grep "05")
echo "dmar:$dmar"
[[ -n "$result" ]] || {
	echo "Check failed!"
	exit 1
}
echo "Check passed!"

