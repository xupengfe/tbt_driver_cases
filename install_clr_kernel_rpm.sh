#!/bin/bash

RPM_NAME=$1
SCRIPT_PATH=$(pwd)
DATE=$(date +%Y-%m-%d_%H_%M)
INSTALL_LOG="/root/Install_kernel_record.log"

usage() {
  cat <<__EOF
  echo "no build.rpm:$build"
  echo "usage: need give the rpm name in present path or absolute rpm path"
  echo "  or no parameter will search and install first matched rpm file"
__EOF
}

print_log() {
  local log_info=$1

  echo "$DATE: $log_info" >> $INSTALL_LOG
}

install_kernel_rpm() {
  local rpm_name=$1
  local build=""

  if [[ -n "$rpm_name" ]]; then
    build=$rpm_name
  else
    build=$(ls -1 kernel-*rpm | head -n 1)
  fi

  [[ -e "$build" ]] || {
    usage
    exit 2
  }

  echo "build:$build"
  print_log "install $build"
  echo "rm -rf $SCRIPT_PATH/lib/modules"
  rm -rf $SCRIPT_PATH/lib/modules
  echo "rm -rf $SCRIPT_PATH/boot/System*"
  rm -rf $SCRIPT_PATH/boot/System*
  echo "rm -rf $SCRIPT_PATH/boot/vmlinu*"
  rm -rf $SCRIPT_PATH/boot/vmlinu*

  echo "rpm2cpio $build | cpio -idmv"
  rpm2cpio $build | cpio -idmv
  [[ $? -eq 0 ]] || {
    echo "rpm2cpio failed, please: swupd bundle-add package-utils to try again"
    print_log "rpm2cpio failed, please: swupd bundle-add package-utils to try again, failed"
    exit 1
  }
  module=$(ls ${SCRIPT_PATH}/lib/modules/)
  [[ -n "$module" ]] || {
    echo "lib/modules is null:$module"
    print_log "lib/modules is null:$module failed"
    exit 1
  }
  echo "rm -rf /usr/lib/modules/$module"
  rm -rf /usr/lib/modules/$module
  sleep 1
  echo "cp -rf ${SCRIPT_PATH}/lib/modules/$module /usr/lib/modules/"
  cp -rf ${SCRIPT_PATH}/lib/modules/$module /usr/lib/modules/
  sleep 1
  echo "cd ${SCRIPT_PATH}/boot/"
  cd ${SCRIPT_PATH}/boot/
  vmlinuz=$(ls ${SCRIPT_PATH}/boot/vmlinuz*)
  system=$(ls ${SCRIPT_PATH}/boot/System*)
  config=$(ls ${SCRIPT_PATH}/boot/config*)
  echo "installkernel $module $vmlinuz $system /boot"
  installkernel $module $vmlinuz $system /boot
  echo "cp -rf $config /lib/kernel/"
  cp -rf $config /lib/kernel/

  node=$(fdisk -l  | grep EFI | tail -n 1 | cut -d ' ' -f 1)
  loader="/mnt/loader/loader.conf"

  echo "umount -f /mnt"
  umount -f /mnt 2>/dev/null
  sleep 1

  echo "mount $node /mnt"
  mount $node /mnt
  [[ -e "$loader" ]] || {
    echo "no $loader file"
    print_log "no $loader file, failed"
    exit 1
  }

  default=$(cat $loader | grep default | head -n 1)
  echo "$default"
  [[ -n "$default" ]] || {
    echo "no default in $loader, add it"
    echo "sed -i 1idefault $module $loader"
    sed -i "1idefault $module" $loader
    echo "install $build with default successfully"
    print_log "install $build with default successfully"
    exit 0
  }
  echo "sed -i s/$default/default linux-$module/g $loader"
  sed -i s/"$default"/"default linux-$module"/g $loader
  echo "install $build successfully"
  print_log "install $build successfully"
}

install_kernel_rpm "$RPM_NAME"
