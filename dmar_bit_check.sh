#!/bin/bash
dmar=""
result=""
dma_file="/sys/bus/thunderbolt/devices/domain0/iommu_dma_protection"
dma_value=$(cat $dma_file)

echo "echo y | acpidump -o -f acpi.dump"
echo y | acpidump -o acpi.dump
echo "acpixtract -f -a acpi.dump"
acpixtract -a acpi.dump
echo "iasl dmar.dat"
iasl dmar.dat

dmar=$(cat dmar.dsl | grep "025h")
result=$(cat dmar.dsl | grep "025h" | grep "05")
echo "dmar:$dmar"
[[ "$dma_value" -eq 1 ]] && {
	echo "Check $dma_file set to 1, passed!"
	exit 0
}

[[ -n "$result" ]] || {
	echo "Check failed!"
	exit 1
}
echo "Check passed!"

