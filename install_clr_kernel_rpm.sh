#!/bin/bash

rpm_name=$1
home=$(pwd)


if [[ -n "$rpm_name" ]]; then
	build=$rpm_name
else
	build=$(ls -1 kernel-*rpm | head -n 1)
fi

[[ -e "$build" ]] || {
	echo "no build.rpm:$build"
	echo "usage: need give the rpm name in present path or absolute rpm path"
	echo "  or no parameter will search and install first matched rpm file"
	exit 1
}

echo "build:$build"
echo "rm -rf $home/lib/modules"
rm -rf $home/lib/modules
echo "rm -rf $home/boot/System*"
rm -rf $home/boot/System*
echo "rm -rf $home/boot/vmlinu*"
rm -rf $home/boot/vmlinu*

echo "rpm2cpio $build | cpio -idmv"
rpm2cpio $build | cpio -idmv
module=$(ls ${home}/lib/modules/)
[[ -n "$module" ]] || {
	echo "lib/modules is null:$module"
	exit 1
}
echo "rm -rf /usr/lib/modules/$module"
rm -rf /usr/lib/modules/$module
sleep 1
echo "cp -rf ${home}/lib/modules/$module /usr/lib/modules/"
cp -rf ${home}/lib/modules/$module /usr/lib/modules/
sleep 1
echo "cd ${home}/boot/"
cd ${home}/boot/
vmlinuz=$(ls ${home}/boot/vmlinuz*)
system=$(ls ${home}/boot/System*)
config=$(ls ${home}/boot/config*)
echo "installkernel $module $vmlinuz $system /boot"
installkernel $module $vmlinuz $system /boot
echo "cp -rf $config /lib/kernel/"
cp -rf $config /lib/kernel/

node=$(fdisk -l  | grep EFI | tail -n 1 | cut -d ' ' -f 1)
loader="/mnt/loader/loader.conf"

echo "umount -f /mnt"
umount -f /mnt
sleep 1

echo "mount $node /mnt"
mount $node /mnt
[[ -e "$loader" ]] || {
	echo "no $loader file"
	exit 1
}

default=$(cat $loader | grep default | head -n 1)
echo "$default"
[[ -n "$default" ]] || {
	echo "no default in $loader, add it"
	echo "sed -i 1idefault $module $loader"
	sed -i "1idefault $module" $loader
	exit 0
}
echo "sed -i s/$default/default linux-$module/g $loader"
sed -i s/"$default"/"default linux-$module"/g $loader
