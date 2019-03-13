#!/bin/bash

home=$(pwd)
build=$(ls -1 kernel-*rpm | head -n 1)
[[ -n "$build" ]] || {
	        echo "no build.rpm:$build"
        return 1
}

echo "build:$build"
echo "rpm2cpio $build | cpio -idmv"
rpm2cpio $build | cpio -idmv
module=$(ls ${home}/lib/modules/)
[[ -n "$module" ]] || {
	echo "lib/modules is null:$module"
	return 1
}
echo "cp -r ${home}/lib/modules/$module /usr/lib/modules/"
cp -r ${home}/lib/modules/$module /usr/lib/modules/
sleep 1
echo "cd ${home}/boot/"
cd ${home}/boot/
vmlinuz=$(ls ${home}/boot/vmlinuz*)
system=$(ls ${home}/boot/System*)
config=$(ls ${home}/boot/config*)
echo "installkernel $module $vmlinuz $system /boot"
installkernel $module $vmlinuz $system /boot
echo "cp $config /lib/kernel/"
cp $config /lib/kernel/
