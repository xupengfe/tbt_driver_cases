
Setup
When testing it is better to have kmemleak, Intel-IOMMU and DMA-API debugging enabled from time to
time:
CONFIG_DEBUG_KMEMLEAK=y
CONFIG_INTEL_IOMMU=y
CONFIG_INTEL_IOMMU_DEFAULT_ON=y
CONFIG_DMA_API_DEBUG=y
The following test cases should be done in both ACPI enumeration (BIOS assisged) and native PCIe
hotplug mode.



Part 1 - TBT BAT case:
1-1   TBT_XS_BAT_CONFIG_TEST tbt_verify_sysfs_mod.sh -t config
      Steps: check kconfig should set below items:
             CONFIG_THUNDERBOLT=m
           CONFIG_THUNDERBOLT_NET=m
       Other value will be failed.
1-2   TBT_XS_BAT_USER_MODE_TEST tbt_verify_sysfs_mod.sh -t user
      Steps: Check if in user mode, will approve all tbt devices.
           Check if in other mode, will check device and domain sysfs files.
       Check all sysfs files should be exist and show content.
1-3   TBT_XS_BAT_LOAD_UNLOAD_MOD_NET_TEST tbt_verify_sysfs_mod.sh -t mod_net
      Steps: Check tbt device connected, if not connect, will conect by clearware
             Load thunderbolt_net driver, check is there abnormal dmesg print
       Unload thunderbolt_net driver, check is there abnormal dmesg print
       Recover if thunderbolt_net driver is loaded before test.
1-4   TBT_XS_BAT_LOAD_UNLOAD_MOD_TEST tbt_verify_sysfs_mod.sh -t mod
      Steps: Check tbt device connected, if not connect, will conect by clearware
             Load thunderbolt driver, check is there abnormal dmesg print
       Unload thunderbolt driver, check is there abnormal dmesg print
       Recover if thunderbolt driver is loaded before test.
1-5   TBT_XS_BAT_MOD_TBT_NET_TIME tbt_verify_sysfs_mod.sh -t mod_net_time
      Steps: Load thunderbolt_net driver and check init time, if more than 10s,
           case will be failed.
       Recover if thunderbolt_net driver is loaded before test
1-6   TBT_XS_BAT_MOD_TBT_TIME tbt_verify_sysfs_mod.sh -t mod_time
      Steps: Load thunderbolt driver and check init time, if more than 10s,
           case will be failed.
       Recover if thunderbolt driver is loaded before test.
1-7   TBT_XS_BAT_BIOS_SET_CHECK tbt_verify_sysfs_mod.sh -t bios_setting
      Steps: Check dmesg log is start from 0.0000s or not
           If yes, check "PCIeHotplug" status to confirm native PCIe or Legacy mode
             Check native PCIe mode, should find "reconfiguring" in dmesg
       Check Legacy mode, should not find "reconfiguring" in dmesg
           Otherwise will fail the case.
1-8   TBT_XS_BAT_ITEM_AUTHORIZED_TEST tbt_verify_sysfs_mod.sh -t item -f authorized
      Steps: Check /sys/bus/thunderbolt/devices/x-x/authorized should exist,
           not null and show content.
1-9   TBT_XS_BAT_ITEM_DEVICE_TEST tbt_verify_sysfs_mod.sh -t item -f device
      Steps: Check /sys/bus/thunderbolt/devices/x-x/device should exist,
           not null and show content.
1-10  TBT_XS_BAT_ITEM_DEVICE_NAME_TEST tbt_verify_sysfs_mod.sh -t item -f device_name
      Steps: Check /sys/bus/thunderbolt/devices/x-x/device_name should exist,
           not null and show content.
1-11  TBT_XS_BAT_ITEM_NVM_AUTH_TEST tbt_verify_sysfs_mod.sh -t item -f nvm_authenticate
      Steps: Check /sys/bus/thunderbolt/devices/x-x/nvm_authenticate should exist,
           and set 0, otherwise will be failed the case
1-12  TBT_XS_BAT_ITEM_NVM_VER_TEST tbt_verify_sysfs_mod.sh -t item -f nvm_version
      Steps: Check /sys/bus/thunderbolt/devices/x-x/nvm_version should exist,
           not null and show content.
1-13  TBT_XS_BAT_ITEM_UEVENT_ID_VER_TEST tbt_verify_sysfs_mod.sh -t item -f uevent
      Steps: Check /sys/bus/thunderbolt/devices/x-x/uevent should exist,
           not null and show content.
1-14  TBT_XS_BAT_ITEM_UNIQUE_ID_VER_TEST tbt_verify_sysfs_mod.sh -t item -f unique_id
      Steps: Check /sys/bus/thunderbolt/devices/x-x/unique_id should exist,
           not null and show content.
1-15  TBT_XS_BAT_ITEM_VENDOR_TEST tbt_verify_sysfs_mod.sh -t item -f vendor
      Steps: Check /sys/bus/thunderbolt/devices/x-x/vendor should exist,
           not null and show content.
1-16  TBT_XS_BAT_ITEM_VENDOR_NAME_TEST tbt_verify_sysfs_mod.sh -t item -f vendor_name
      Steps: Check /sys/bus/thunderbolt/devices/x-x/vendor_name should exist,
           not null and show content.
1-17  TBT_XS_BAT_DOMAIN_SECURITY_TEST tbt_verify_sysfs_mod.sh -t domain -f security
      Steps: Check /sys/bus/thunderbolt/devices/domainx/security exist,
           not null and show content.
1-18  TBT_XS_BAT_DOMAIN_UEVENT_TEST tbt_verify_sysfs_mod.sh -t domain -f uevent
      Steps: Check /sys/bus/thunderbolt/devices/domainx/uevent exist,
           not null and show content.
1-19  TBT_XS_BAT_DEVICE_TOPO_CHECK tbt_verify_sysfs_mod.sh -t topo
      Steps: Check tbt device connected, and check topology
           show all route string and device_name.
1-20  TBT_XS_FUNC_NONE_MODE_TEST tbt_func_test.sh -s none
      Steps: Security was set none, check tbt device connected,
           all authorized should set 1
1-21  TBT_XS_FUNC_USER_MODE_TEST tbt_func_test.sh -s user
      Steps: Security was set user, check tbt device connected,
           set authorized to 1 successfully
1-22 TBT_XS_FUNC_SECURE_MODE_WRONG tbt_func_test.sh -s secure_wrong
      Steps: Security was set secure, check tbt device connected,
           set key in sysfs key, and update key by fill 1 in authorized successfully
1-23 TBT_XS_FUNC_SECURE_MODE_VERIFY tbt_func_test.sh -s secure_verify
      Steps:

TBT_XS_FUNC_DPONLY_MODE_TEST tbt_func_test.sh -s dp
      Steps:

TBT_XS_FUNC_RW_TBT_SSD_10M tbt_ssd_read_write.sh -b 1MB -c 10 -p ssd -t 10
      Steps:

TBT_XS_FUNC_RW_TBT_SSD_100M tbt_ssd_read_write.sh -b 1MB -c 100 -p ssd -t 10
      Steps:

TBT_XS_FUNC_RW_TBT_SSD_500M tbt_ssd_read_write.sh -b 10MB -c 50 -p ssd -t 5
      Steps:

TBT_XS_FUNC_RW_TBT_SSD_1000M tbt_ssd_read_write.sh -b 10MB -c 100 -p ssd -t 5
      Steps:

TBT_XS_FUNC_RW_2.0_FLASH tbt_ssd_read_write.sh -b 1MB -c 100 -p 2.0 -d flash -t 2
      Steps:

TBT_XS_FUNC_RW_3.0_FLASH tbt_ssd_read_write.sh -b 1MB -c 100 -p 3.0 -d flash -t 2
      Steps:

TBT_XS_FUNC_MONITOR_NONE_TEST tbt_func_test.sh -s monitor_none
      Steps:

TBT_XS_FUNC_MONITOR_USER_TEST tbt_func_test.sh -s monitor_user
      Steps:

TBT_XS_FUNC_MONITOR_SECURE_TEST tbt_func_test.sh -s monitor_secure
      Steps:

TBT_XS_FUNC_MONITOR_DP_TEST tbt_func_test.sh -s monitor_dp
      Steps:

TBT_XS_FUNC_PLUG_OUT_TEST tbt_func_test.sh -s po
      Steps:

TBT_XS_FUNC_USER_PLUG_IN_CHECK tbt_func_test.sh -s upic
      Steps:

TBT_XS_FUNC_USER_PLUG_IN_ERROR_CHECK tbt_func_test.sh -s upie
      Steps:

TBT_XS_FUNC_USER_PLUG_IN_ACC_CHECK tbt_func_test.sh -s upiac
      Steps:

TBT_XS_FUNC_USER_PLUG_IN_ACC_ERROR tbt_func_test.sh -s upiae
      Steps:

TBT_XS_FUNC_SECURE_PLUG_IN_CHECK tbt_func_test.sh -s spic
      Steps:

TBT_XS_FUNC_SECURE_PLUG_IN_ERROR_CHECK tbt_func_test.sh -s spie
      Steps:

TBT_XS_FUNC_SECURE_PLUG_IN_APPROVE tbt_func_test.sh -s spiaw
      Steps:

TBT_XS_FUNC_SECURE_PLUG_IN_UPDATE_KEY tbt_func_test.sh -s spiu
      Steps:

TBT_XS_FUNC_SECURE_PLUG_IN_VERIFY_KEY tbt_func_test.sh -s spiv
      Steps:

TBT_XS_FUNC_COMMON_SSD_TRANS_POI tbt_func_test.sh -s po_transfer -p ssd -d device
      Steps:

TBT_XS_FUNC_COMMON_USB2.0_TRANS_POI tbt_func_test.sh -s po_transfer -p 2.0 -d flash
      Steps:

TBT_XS_FUNC_COMMON_USB3.0_TRANS_POI tbt_func_test.sh -s po_transfer -p 3.0 -d flash
      Steps:

TBT_XS_FUNC_COMMON_HOTPLUG_CHECK tbt_func_test.sh -s poi -p 10
      Steps:

TBT_XS_FUNC_NVM_DOWNGRADE tbt_func_test.sh -s nvm_downgrade
      Steps:

TBT_XS_FUNC_NVM_UPGRADE tbt_func_test.sh -s nvm_upgrade
      Steps:

TBT_XS_FUNC_ACL_CHECK tbt_preboot_acl.sh -s acl_check
      Steps:

TBT_XS_FUNC_ACL_CLEAN tbt_preboot_acl.sh -s acl_clean
      Steps:

TBT_XS_FUNC_ACL_CLEAN_PLUG tbt_preboot_acl.sh -s acl_clean_plug
      Steps:

TBT_XS_FUNC_ACL_WRONG tbt_preboot_acl.sh -s acl_wrong
      Steps:

TBT_XS_FUNC_ACL_SET_FIRST tbt_preboot_acl.sh -s acl_set_first
      Steps:

TBT_XS_FUNC_ACL_CLEAN_RECOVER tbt_preboot_acl.sh -s acl_clean_recover
      Steps:

TBT_XS_FUNC_ACL_SET_ALL tbt_preboot_acl.sh -s acl_set_all
      Steps:

TBT_XL_STRESS_COMMON_HOTPLUG tbt_func_test.sh -s poi -p 100
      Steps:
TBT_XS_FUNC_FREEZE_TBT_TEST tbt_func_test.sh -s suspend -t freeze -p tbt
      Steps:

TBT_XS_FUNC_FREEZE_SSD_RW tbt_func_test.sh -s suspend -t freeze -p ssd
      Steps:

TBT_XS_FUNC_FREEZE_MONITOR_TEST tbt_func_test.sh -s suspend -t freeze -p monitor
      Steps:

TBT_XS_FUNC_S2IDLE_TBT_TEST tbt_func_test.sh -s suspend -t s2idle -p tbt
      Steps:

TBT_XS_FUNC_S2IDLE_SSD_RW tbt_func_test.sh -s suspend -t s2idle -p ssd
      Steps:

TBT_XS_FUNC_S2IDLE_MONITOR_TEST tbt_func_test.sh -s suspend -t s2idle -p monitor
      Steps:

TBT_XS_FUNC_S3_TBT_TEST tbt_func_test.sh -s suspend -t deep -p tbt
      Steps:

TBT_XS_FUNC_S3_SSD_RW tbt_func_test.sh -s suspend -t deep -p ssd
      Steps:

TBT_XS_FUNC_S3_MONITOR_TEST tbt_func_test.sh -s suspend -t deep -p monitor
      Steps:

TBT_XS_FUNC_ADM_TOPO tbt_tools.sh -s adm_topo
      Steps:

TBT_XS_FUNC_ADM_APPROVE_ALL tbt_tools.sh -s adm_approve_all
      Steps:

TBT_XS_FUNC_ADM_DEVICES tbt_tools.sh -s adm_devices
      Steps:

TBT_XS_FUNC_ADM_ACL tbt_tools.sh -s adm_acl
      Steps:

TBT_XS_FUNC_ADM_RM_FIRST tbt_tools.sh -s adm_remove_first
      Steps:

TBT_XS_FUNC_ADM_RM_ALL tbt_tools.sh -s adm_remove_all
      Steps:

