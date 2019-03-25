#!/bin/bash
dmar=""
result=""
echo "acpidump -f -o acpi.dump"
acpidump -f -o acpi.dump
echo "acpixtract -f -a acpi.dump"
acpixtract -f -a acpi.dump
echo "iasl dmar.dat"
iasl dmar.dat

dmar=$(cat dmar.dsl | grep "025h")
result=$(cat dmar.dsl | grep "025h" | grep "05")
echo "dmar:$dmar"
[[ -n "$result" ]] || {
	echo "Check failed!"
	exit 1
}
echo "Check passed!"

