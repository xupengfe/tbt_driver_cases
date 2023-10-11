#!/bin/bash

INITRAM=$1
DG2_GUC="dg2_guc_70.bin"
DG2_HUC="dg2_huc_gsc.bin"
HOST_I915="/lib/firmware/i915"
TARGET_FOLDER="/root/test"
TAR_FILE="initramfs"

usage() {
  echo "Need parm initramfs file like: /boot/initramfs-6.6.0-rc4-2023-10-06-intel-next+.img, exit"
  exit 1
}

check_host_dg2() {
  [[ -e "${HOST_I915}/${DG2_GUC}" ]] || {
    echo "No ${HOST_I915}/${DG2_GUC}, https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git copy i915 folder in $HOST_I915."
    exit 1
  }

  [[ -e "${HOST_I915}/${DG2_HUC}" ]] || {
    echo "No ${HOST_I915}/${DG2_HUC}, https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git copy i915 folder in $HOST_I915."
    exit 1
  }
}

install_initramfs() {
  local initram=$1
  local size=""

  [[ -z "$initram" ]] && usage

  [[ -e "$initram" ]] || {
    echo "initramfs file does not exist: $initram"
    usage
  }

  rm -rf "$TARGET_FOLDER"
  mkdir -p "$TARGET_FOLDER"
  cd "$TARGET_FOLDER" || {
    echo "Access $TARGET_FOLDER failed"
    exit 1
  }
  echo "/usr/lib/dracut/skipcpio $initram | gunzip -c | cpio -idmv"
  /usr/lib/dracut/skipcpio "$initram" | gunzip -c | cpio -idmv

  # Check initramfs folder dg2
  [[ -e "${TARGET_FOLDER}/lib/firmware/i915/${DG2_GUC}" && -e "${TARGET_FOLDER}/lib/firmware/i915/${DG2_HUC}" ]] && {
    echo "${TARGET_FOLDER}/lib/firmware/i915/ contains $DG2_GUC and $DG2_HUC, done, nothing to do."
    return 0
  }

  echo "cp -rf $HOST_I915 ${TARGET_FOLDER}/lib/firmware/"
  cp -rf "$HOST_I915" "${TARGET_FOLDER}/lib/firmware/"

  cd "${TARGET_FOLDER}" || {
    echo "Access $TARGET_FOLDER failed."
    exit 1
  }

  rm -rf ../${TAR_FILE}
  echo "find . | cpio -o -H newc > /root/${TAR_FILE}"
  find . | cpio -o -H newc > /root/${TAR_FILE}

  cd /root/ || {
    echo "Access /root/ failed."
    exit 1
  }

  gzip -c /root/${TAR_FILE} > /root/${TAR_FILE}.img
  size=$(du -s /root/${TAR_FILE}.img)
  if [[ "$size" == "0"*  ]]; then
    echo "size is 0: $size! Exit!"
    exit 1
  else
    echo "/root/${TAR_FILE}.img size:$size"
  fi

  echo "cp -rf /root/${TAR_FILE}.img $initram"
  cp -rf /root/${TAR_FILE}.img "$initram"
}

check_host_dg2
install_initramfs "$INITRAM"
