#!/bin/bash
dmar=""
result=""

echo "echo y | acpidump -o -f acpi.dump"
echo y | acpidump -o acpi.dump
echo "acpixtract -f -a acpi.dump"
acpixtract -a acpi.dump
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

