                          Linux TBT driver test cases

You can find the related info in: https://github.com/xupengfe/tbt_driver_cases
TBT: thunderbolt

Setup:
  When testing it is better to have kmemleak, Intel-IOMMU and DMA-API debugging enabled
  from time to time:
    CONFIG_DEBUG_KMEMLEAK=y
    CONFIG_INTEL_IOMMU=y
    CONFIG_INTEL_IOMMU_DEFAULT_ON=y
    CONFIG_DMA_API_DEBUG=y
  The following test cases should be done in both ACPI enumeration (BIOS assisged) and
  native PCIe hotplug mode.


_________________________________________________________________________________________
*****************************************************************************************
Usage:
Due to split none/user/secure/dp mode tests and common tests, use below commands
to execute tbt cases:
-> For common tests, run the common cases which is not related with tbt mode:
./runtests.sh -p cfl-h-rvp -P cfl-h-rvp -g tbt_common_subset -o /opt/logs/tbt -c

-> For none/user/secure/dp mode tests:
  In none mode, please run:
./runtests.sh -p cfl-h-rvp -P cfl-h-rvp -f ddt_intel/tbt_none_tests -o /opt/logs/tbt -c

  In user mode, please run:
./runtests.sh -p cfl-h-rvp -P cfl-h-rvp -f ddt_intel/tbt_user_tests -o /opt/logs/tbt -c

  In secure mode, please run:
./runtests.sh -pcfl-h-rvp -P cfl-h-rvp -f ddt_intel/tbt_secure_tests -o /opt/logs/tbt -c

  In dp mode, please run:
./runtests.sh -p cfl-h-rvp -P cfl-h-rvp -f ddt_intel/tbt_dp_tests -o /opt/logs/tbt -c
*****************************************************************************************
_________________________________________________________________________________________



Part 1 - TBT BAT tests:
Command sample: "./runtests.sh -p cfl-s_cnl-h -P cfl-s_cnl-h -f ddt_intel/tbt_bat_tests -o /opt/logs/tbt_bat -c"
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
      Steps: Load thunderbolt_net driver and check init time, if more than 9s,
             case will be failed.

             Recover if thunderbolt_net driver is loaded before test
1-6   TBT_XS_BAT_MOD_TBT_TIME tbt_verify_sysfs_mod.sh -t mod_time
      Steps: Load thunderbolt driver and check init time, if more than 9s,
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
             and set 0, otherwise will be failed the case.

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


Part 2 - TBT basic function tests:
Command sample: "./runtests.sh -p cfl-s_cnl-h -P cfl-s_cnl-h -f ddt_intel/tbt_func_tests -o /opt/logs/tbt_func -c"
2-1   TBT_XS_FUNC_RW_TBT_SSD_10M tbt_ssd_read_write.sh -b 1MB -c 10 -p ssd -t 10
      Steps: Except dponly mode, check tbt device connected,
             find ssd connected with tbt, transfer one 10M file into ssd by dd,
             transfer the 10M file in ssd to platform, and compare the 10M file
             should be same.

2-2   TBT_XS_FUNC_RW_TBT_SSD_100M tbt_ssd_read_write.sh -b 1MB -c 100 -p ssd -t 10
      Steps: Except dponly mode, check tbt device connected,
             find ssd connected with tbt, transfer one 100M file into ssd by dd,
             transfer the 100M file in ssd to platform, and compare the 100M file
             should be same.

2-3   TBT_XS_FUNC_RW_TBT_SSD_500M tbt_ssd_read_write.sh -b 10MB -c 50 -p ssd -t 5
      Steps: Except dponly mode, check tbt device connected,
             find ssd connected with tbt, transfer one 500M file into ssd by dd,
             transfer the 500M file in ssd to platform, and compare the 500M file
             should be same.

2-4   TBT_XS_FUNC_RW_TBT_SSD_1000M tbt_ssd_read_write.sh -b 10MB -c 100 -p ssd -t 5
      Steps: Except dponly mode, check tbt device connected,
             find ssd connected with tbt, transfer one 1000M file into ssd by dd,
             transfer the 1000M file in ssd to platform, and compare the 1000M file
             should be same.

2-5  TBT_XS_FUNC_RW_2.0_FLASH tbt_ssd_read_write.sh -b 1MB -c 100 -p 2.0 -d flash -t 2
      Steps: Except dponly mode, check tbt device connected,
             find usb2.0 connected with tbt, transfer one 100M file into usb2.0 by dd,
             transfer the 100M file from usb2.0 to platform, and compare the 100M file
             should be same.

2-6  TBT_XS_FUNC_RW_3.0_FLASH tbt_ssd_read_write.sh -b 1MB -c 100 -p 3.0 -d flash -t 2
      Steps: Except dponly mode, check tbt device connected,
             find usb3.0 connected with tbt, transfer one 100M file into usb3.0 by dd,
             transfer the 100M file from usb3.0 to platform, and compare the 100M file
             should be same.


Part 3 - TBT hotplug function tests:
Command sample: "./runtests.sh -p cfl-h-rvp -P cfl-h-rvp -f ddt_intel/tbt_hotplug_tests -o /opt/logs/tbt_hotplug -c"
3-1   TBT_XS_FUNC_COMMON_SSD_TRANS_POI tbt_func_test.sh -s po_transfer -p ssd -d device
      Steps: Except dp mode, plug in tbt devices which connected ssd, appove tbt access,
             transfer 600M file into ssd, when transfer file is ongoing, plug out all
             tbt devices, 30s later plug in tbt devices should without issue, and transfer
             600M file in ssd successfully.

3-2   TBT_XS_FUNC_COMMON_USB2.0_TRANS_POI tbt_func_test.sh -s po_transfer -p 2.0 -d flash
      Steps: Except dp mode, plug in tbt devices which connected usb2.0, appove tbt access,
             transfer 600M file into usb2.0, when transfer file is ongoing, plug out all
             tbt devices, 30s later plug in tbt devices should without issue, and transfer
             600M file in 2.0 successfully.

3-3   TBT_XS_FUNC_COMMON_USB3.0_TRANS_POI tbt_func_test.sh -s po_transfer -p 3.0 -d flash
      Steps: Except dp mode, plug in tbt devices which connected usb3.0, appove tbt access,
             transfer 600M file into usb3.0, when transfer file is ongoing, plug out all
             tbt devices, 30s later plug in tbt devices should without issue, and transfer
             600M file in 3.0 successfully.

3-4   TBT_XS_FUNC_COMMON_HOTPLUG_CHECK tbt_func_test.sh -s poi -p 10
      Steps: In none mode, plug/unplug test 10 times, after unplug, authorized should
             set 1.
             In user mode, plug/unplug test 10 times, after unplug, authorized should
             set 0, and approve to access.
             In secure mode, plug/unplug test 10 times, after unplug, authorzied should
             set 0, and approve to access with key verify.
             In dp mode, plug/unplug test 10 times, after unplug, authorzied should set 0,
             approve to access.
             All above mode, check tbt topo is the same as last time unplug status.


Part 4 - TBT NVM downgrade upgrade tests:
Command sample: "./runtests.sh -p cfl-h-rvp -P cfl-h-rvp -f ddt_intel/tbt_nvm_tests -o /opt/logs/tbt_nvm -c"
4-1   TBT_XS_FUNC_NVM_DOWNGRADE tbt_func_test.sh -s nvm_downgrade
      Steps: Save the nvm version before downgrade, copy nvm downgrade file in
             /sys/bus/thunderbolt/devices/0-0/nvm_non_active0/nvmem, set 1 into
             /sys/bus/thunderbolt/devices/0-0/nvm_authenticate to start NVM
             downgrade, after nvm_authenticate changed to 0, otherwise will
             fail the case, check nvm version is expected.

4-2   TBT_XS_FUNC_NVM_UPGRADE tbt_func_test.sh -s nvm_upgrade
      Steps: Save the nvm version before upgrade, copy nvm upgrade file in
             /sys/bus/thunderbolt/devices/0-0/nvm_non_active0/nvmem, set 1 into
             /sys/bus/thunderbolt/devices/0-0/nvm_authenticate to start NVM
             upgrade, after nvm_authenticate changed to 0, otherwise will
             fail the case, check nvm version is expected.

4-3   TBT_XS_FUNC_EP_DOWNGRADE tbt_func_test.sh -s ep_downgrade
      Steps: Found tbt EP device, if no will fail the case. Save the nvm
             version before downgrade, copy nvm downgrade file for EP in
             /sys/bus/thunderbolt/devices/0-X/nvm_non_activeX/nvmem, set 1 into
             /sys/bus/thunderbolt/devices/0-X/nvm_authenticate to start NVM
             EP downgrade, after nvm_authenticate changed to 0, otherwise will
             fail the case, check nvm version is expected.

4-4   TBT_XS_FUNC_EP_UPGRADE tbt_func_test.sh -s ep_upgrade
      Steps: Found tbt EP device, if no will fail the case. Save the nvm
             version before upgrade, copy nvm upgrade file for EP in
             /sys/bus/thunderbolt/devices/0-X/nvm_non_activeX/nvmem, set 1 into
             /sys/bus/thunderbolt/devices/0-X/nvm_authenticate to start NVM
             EP upgrade, after nvm_authenticate changed to 0, otherwise
             fail the case, check nvm version should the same as before nvm
             test, if no will print the warning.

Part 5 - TBT Preboot ACL tests:
Command sample: "./runtests.sh -p cfl-h-rvp -P cfl-h-rvp -f ddt_intel/tbt_preboot_tests -o /opt/logs/tbt_preboot -c"
5-1   TBT_XS_FUNC_ACL_CHECK tbt_preboot_acl.sh -s acl_check
      Steps: Check user or secure mode, other mode will not test,
             check tbt devices connected, check
             /sys/bus/thunderbolt/devices/domain0/boot_acl contain ","

5-2   TBT_XS_FUNC_ACL_CLEAN tbt_preboot_acl.sh -s acl_clean
      Steps: Check user or secure mode, other mode will not test,
             Clean boot_acl, boot_acl should set as ",,,,,,,,,,,,,,,"

5-3   TBT_XS_FUNC_ACL_CLEAN_PLUG tbt_preboot_acl.sh -s acl_clean_plug
      Steps: Check user or secure mode, other mode will not test,
             plug and unplug tbt devices, all tbt router authorized
             set 0.

5-4   TBT_XS_FUNC_ACL_WRONG tbt_preboot_acl.sh -s acl_wrong
      Steps: Fill invalid string into boot_acl, all should reject.

5-5   TBT_XS_FUNC_ACL_SET_FIRST tbt_preboot_acl.sh -s acl_set_first
      Steps: Set first connnect tbt device in boot_acl, should return success.

5-6   TBT_XS_FUNC_ACL_CLEAN_RECOVER tbt_preboot_acl.sh -s acl_clean_recover
      Steps: Clean boot_acl file should return success, plug and unplug to
             check boot_acl content is ",,,,,,,,,,,,,,,"

5-7   TBT_XS_FUNC_ACL_SET_ALL tbt_preboot_acl.sh -s acl_set_all
      Steps: Check all tbt devices connnected, fill in all tbt uuid in boot_acl,
             should return success, and check all uuid in boot_acl.


Part 6 - TBT stress tests:
6-1   TBT_XL_STRESS_COMMON_HOTPLUG tbt_func_test.sh -s poi -p 100
      Steps: Check tbt devices connected, and check tbt mode,
             plug and unplug tbt devices 100 times, approve all tbt devices to access,
             all authorized should not 0, and topo is the same as last time.


Part 7 - TBT sleep tests:
Command sample: "./runtests.sh -p cfl-h-rvp -P cfl-h-rvp -f ddt_intel/tbt_suspend_resume_tests -o /opt/logs/tbt_sleep -c"
7-1   TBT_XS_FUNC_FREEZE_TBT_TEST tbt_func_test.sh -s suspend -t freeze -p tbt
      Steps: Check tbt devices connected, and "rtcwake -m freeze -s 20",
             after wake up, check topo is the same as before sleep and
             show common sysfs file.

7-2   TBT_XS_FUNC_FREEZE_SSD_RW tbt_func_test.sh -s suspend -t freeze -p ssd
      Steps: Check tbt devices connected, one ssd connnected to tbt device,
             "rtcwake -m freeze -s 20", after wake up, check transfer file
             to ssd, and copy the file to platform, file should be consistent.

7-3   TBT_XS_FUNC_FREEZE_MONITOR_TEST tbt_func_test.sh -s suspend -t freeze -p monitor
      Steps: Check tbt devices connected, one tbt monitor should be connected,
             "rtcwake -m freeze -s 20", after wake up, check tbt monitor sysfs file
             should come back, and check monitor sysfile content as expected.

7-4   TBT_XS_FUNC_S2IDLE_TBT_TEST tbt_func_test.sh -s suspend -t s2idle -p tbt
      Steps: Check tbt devices connected, and set s2idle and execute mem sleep,
             after wake up, check topo is the same as before sleep and
             show common sysfs file.

7-5   TBT_XS_FUNC_S2IDLE_SSD_RW tbt_func_test.sh -s suspend -t s2idle -p ssd
      Steps: Check tbt devices connected, one ssd connnected to tbt device,
             and set s2idle and execute mem sleep, after wake up, check transfer file
             to ssd, and copy the file to platform, file should be consistent.

7-6   TBT_XS_FUNC_S2IDLE_MONITOR_TEST tbt_func_test.sh -s suspend -t s2idle -p monitor
      Steps: Check tbt devices connected, one tbt monitor should be connected,
             and set s2idle and execute mem sleep, after wake up, check tbt monitor
             sysfs file should come back, and check monitor sysfile content as expected.

7-7   TBT_XS_FUNC_S3_TBT_TEST tbt_func_test.sh -s suspend -t deep -p tbt
      Steps: Check tbt devices connected, and set deep and execute mem sleep,
             after wake up, check topo is the same as before sleep and
             show common sysfs file.

7-8   TBT_XS_FUNC_S3_SSD_RW tbt_func_test.sh -s suspend -t deep -p ssd
      Steps: Check tbt devices connected, one ssd connnected to tbt device,
             and set deep and execute mem sleep, after wake up, check transfer file
             to ssd, and copy the file to platform, file should be consistent.

7-9   TBT_XS_FUNC_S3_MONITOR_TEST tbt_func_test.sh -s suspend -t deep -p monitor
      Steps: Check tbt devices connected, one tbt monitor should be connected,
             and set deep and execute mem sleep, after wake up, check tbt monitor
             sysfs file should come back, and check monitor sysfile content as expected.

7-10  TBT_XS_FUNC_S4_TBT_TEST tbt_func_test.sh -s suspend -t disk -p tbt
      Steps: Connect thunderbolt deivces and test s4, rtcwake -m disk -s 40,
             check TBT connection after s4 sleep.

7-11  TBT_XS_FUNC_S4_SSD_RW tbt_func_test.sh -s suspend -t disk -p ssd
      Steps: Connect thunderbolt deivces and test s4, rtcwake -m disk -s 40,
             check TBT SSD read write function

7-12  TBT_XS_FUNC_S4_MONITOR_TEST tbt_func_test.sh -s suspend -t disk -p monitor
      Steps: Connect thunderbolt deivces and test s4, rtcwake -m disk -s 40,
             check TBT monitor 5K works well or not


Part 8 - TBT user space tests:
Command sample:"./runtests.sh -p cfl-h-rvp -P cfl-h-rvp -f ddt_intel/tbt_userspace_tests -o /opt/logs/tbt_userspace -c"
8-1   TBT_XS_FUNC_ADM_TOPO tbt_tools.sh -s adm_topo
      Steps: plug out tbt devices and then plug in tbt devices, check tbt
             device connected, tried "tbtadm topology", executed return success,
             result should contain "Controller" "Security" "Route-string"

8-2   TBT_XS_FUNC_ADM_APPROVE_ALL tbt_tools.sh -s adm_approve_all
      Steps: check tbt device connected, tried "tbtadm approve-all", executed return
             success, authorized content should not 0 and no tbt abnormal dmesg.

8-3   TBT_XS_FUNC_ADM_DEVICES tbt_tools.sh -s adm_devices
      Steps: check tbt device connected, tried "tbtadm devices", executed return success,
             check all route string in the results.

8-4   TBT_XS_FUNC_ADM_ACL tbt_tools.sh -s adm_acl
      Steps: check tbt device connected, tried "tbtadm acl", executed return success,
             check all tbt devices uuid in the results.

8-5   TBT_XS_FUNC_ADM_RM_FIRST tbt_tools.sh -s adm_remove_first
      Steps: check tbt device connected, tried "tbtadm remove 0-?"(1 or 3),
             executed return success, and no 0-? folder in /var/lib/thunderbolt/acl.

8-6   TBT_XS_FUNC_ADM_RM_ALL tbt_tools.sh -s adm_remove_all
      Steps: check tbt device connected, "tbtadm remove-all", executed return success,
             no any file in /var/lib/thunderbolt.


Part 9 - TBT none mode tests:
Command sample:"./runtests.sh -p cfl-s_cnl-h -P cfl-s_cnl-h -f ddt_intel/tbt_none_tests -o /opt/logs/tbt -c"
9-1   TBT_XS_FUNC_NONE_MODE_TEST tbt_func_test.sh -s none
      Steps: Security was set none, check tbt device connected,
             all authorized should set 1.

9-2   TBT_XS_FUNC_MONITOR_NONE_TEST tbt_func_test.sh -s monitor_none
      Steps: Find tbt 5K monitor in none mode, and check authorized should set 1.


Part 10 - TBT user mode tests:
Command sample:"./runtests.sh -p cfl-s_cnl-h -P cfl-s_cnl-h -f ddt_intel/tbt_user_tests -o /opt/logs/tbt -c"
10-1  TBT_XS_FUNC_USER_MODE_TEST tbt_func_test.sh -s user
      Steps: Security was set user, check tbt device connected,
             set authorized to 1 successfully.

10-2  TBT_XS_FUNC_MONITOR_USER_TEST tbt_func_test.sh -s monitor_user
      Steps: Find tbt 5K monitor in user mode, and set 1 in authorized, and return success.

10-3  TBT_XS_FUNC_USER_PLUG_OUT_TEST tbt_func_test.sh -s po
      Steps: Check tbt devices connected and set user mode, then plug out all tbt devices,
             30s later, check no tbt router like 0-1 folder exist in sysfs.

10-4  TBT_XS_FUNC_USER_PLUG_IN_CHECK tbt_func_test.sh -s upic
      Steps: In user mode, check tbt devices connected, check all tbt router folders exist
             in sysfs files /sys/bus/thunderbolt/devices, all tbt router authorized should
             set 0.

10-5  TBT_XS_FUNC_USER_PLUG_IN_ERROR_CHECK tbt_func_test.sh -s upie
      Steps: In user mode, check tbt devices connected, fill in invalid string in
             authorized, all these action should reject.

10-6  TBT_XS_FUNC_USER_PLUG_IN_ACC_CHECK tbt_func_test.sh -s upiac
      Steps: In user mode, check tbt devices connected, set 1 to authorized, should return
             success, check lspci should contain thunderbolt.

10-7  TBT_XS_FUNC_USER_PLUG_IN_ACC_ERROR tbt_func_test.sh -s upiae
      Steps: In user mode, check tbt devices connected, all tbt router authorized set 1,
             fill in invalid string in authorized, should reject.


Part 11 - TBT secure mode tests:
Command sample:"./runtests.sh -p cfl-s_cnl-h -P cfl-s_cnl-h -f ddt_intel/tbt_secure_tests -o /opt/logs/tbt -c"
11-1  TBT_XS_FUNC_SECURE_MODE_WRONG tbt_func_test.sh -s secure_wrong
      Steps: Security was set secure, check tbt device connected,
             set wrong key in sysfs key, and fill 2 to authorized try to approve,
             which should be rejected due to wrong key, otherwise case will be failed.

11-2  TBT_XS_FUNC_SECURE_MODE_VERIFY tbt_func_test.sh -s secure_verify
      Steps: Security was set secure, check tbt device connected,
             set new key in sysfs key, and fill 1 to authorized try to update key
             and approve, which should return success.

11-3  TBT_XS_FUNC_MONITOR_SECURE_TEST tbt_func_test.sh -s monitor_secure
      Steps: Find tbt 5K monitor in secure mode, and verify corrected key, authorized
             should set 2 when correct key is setted, set 1 when correct key is not
             found and update new key.

11-4  TBT_XS_FUNC_SECURE_PLUG_OUT_TEST tbt_func_test.sh -s po
      Steps: Check tbt connected and in secure mode, then plug out all tbt devices,
             30s later, check no tbt router like 0-1 folder exist in sysfs.

11-5  TBT_XS_FUNC_SECURE_PLUG_IN_CHECK tbt_func_test.sh -s spic
      Steps: In secure mode, plug in all tbt devices, tbt router authorized should set 0.

11-6  TBT_XS_FUNC_SECURE_PLUG_IN_ERROR_CHECK tbt_func_test.sh -s spie
      Steps: In secure mode, plug in all tbt devices, input invalid string in authorized,
             all these actions return fail.

11-7  TBT_XS_FUNC_SECURE_PLUG_IN_APPROVE tbt_func_test.sh -s spiaw
      Steps: In secure mode, check tbt devices connected, set 1 into authorized without
             key, return success, and all tbt devices approve to access.

11-8  TBT_XS_FUNC_SECURE_PLUG_IN_UPDATE_KEY tbt_func_test.sh -s spiu
      Steps: In secure mode, plug out all tbt devices, and plug in, set the new key in
             sysfs key, then set 1 into authorized, should return success, and all tbt
             approve to access, and update the new key successfully.

11-9  TBT_XS_FUNC_SECURE_PLUG_IN_VERIFY_KEY tbt_func_test.sh -s spiv
      Steps: In secure mode, plug out all tbt devices, and plug in, set the key last
             time update, set 2 into authorized, should return success, all tbt appove
             to access.

Part 12 - TBT dp only mode tests:
Command sample:"./runtests.sh -p cfl-s_cnl-h -P cfl-s_cnl-h -f ddt_intel/tbt_dp_tests -o /opt/logs/tbt -c"
12-1  TBT_XS_FUNC_DPONLY_MODE_TEST tbt_func_test.sh -s dp
      Steps: Security was set dponly, check tbt device connected,
             set 1 to authorized file, and no usb and sata connected by tbt find.

12-2  TBT_XS_FUNC_MONITOR_DP_TEST tbt_func_test.sh -s monitor_dp
      Steps: Connect tbt 5K monitor, and approve 5K monitor accees,
             check 5K monitor device is recognized.

Part 13 - TBT usb only mode tests:
Command sample: reserved
Cases: reserved
Plan 4 cases to check: usb detected automatically, usb2.0/3.0 transfer ok,
sata interface should not be detected.


Part 14 - TBT RTD3 tests:
Command sample:"./runtests.sh -p cfl-h-rvp -P cfl-h-rvp -f ddt_intel/tbt_rtd3_tests -o /opt/logs/tbt -c"
14-1  TBT_XS_FUNC_RTD3_INIT
      Steps: check after disconnected tbt, /sys/bus/thunderbolt/devices/0-0/power/control
             should set auto. If not, will fail the case.

14-2  TBT_XS_FUNC_RTD3_HOST_D3
      Steps: check after disconnected tbt, /sys/bus/thunderbolt/devices/0-0/power/control
             should set auto. After 8s idle, host controller bus should be in D3

14-3  TBT_XS_FUNC_RTD3_HOST_BUSY
      Steps: check after disconnected tbt, /sys/bus/thunderbolt/devices/0-0/power/control
             should set auto, check host preboot acl, and tbt host bus should be in D0,
             after idle 8s tbt host bus should be in D3 again

14-4  TBT_XS_FUNC_RTD3_HOST_ON_CHECK
      Steps: check after disconnected tbt, /sys/bus/thunderbolt/devices/0-0/power/control
             set to on successfully, and idle 8s, host bus should be in D0.
             set 0-0/power/control to auto back, idle 8s, host bus should be in D3.

14-5  TBT_XS_FUNC_RTD3_HOST_XHCI_CHECK
      Steps: Plug out all tbt devices, host router should contain xhci, if not,
             will block this test. If it contain xhci, will set xhci power/control to auto,
             and check 8s later in D3.

14-6  TBT_XS_FUNC_RTD3_HOST_UNLOAD_DRIVER
      Steps: Plug out all tbt devices, let host 0-0 in idle 8s, unload thunderbolt driver,
             check host PCI should be in D0.

14-7  TBT_XS_FUNC_RTD3_HOST_LOAD_DRIVER
      Steps: Plug out all tbt devices, load thunderbolt driver,at first host in D0,
             and then let host idle 8s, check host PCI should be in D3.

14-8  TBT_XS_FUNC_RTD3_freeze_test
      Steps: Check host controller was in D3 mode, and then freeze sleep, after wake up
             and wait 8s, controller should in D3 again.

14-9  TBT_XS_FUNC_RTD3_S3_test
      Steps: Check host controller was in D3 mode, and then S3 sleep, after wake up
             and wait 8s, host controller should in D3 again.

14-10 TBT_XS_FUNC_RTD3_PLUGIN_HOST_CHECK
      Steps: Plug in thunderbolt devices, check host PCI in D0 status, due to xhci and
             ahci is on not auto mode.

14-11 TBT_XS_FUNC_RTD3_PLUGIN_XHCI
      Steps: Set all xhci and ahci in tbt pci bus power/control with auto.
             for example: "echo auto > /sys/bus/pci/devices/0000:37:00.0/power/control",
             all should return success. And after idle 8s, xhci should be in D3

14-12 TBT_XS_FUNC_RTD3_PLUGIN_AHCI
      Steps: Set all ahci in tbt pci bus power/control with auto. Check AHCI should be
             in D3 after 30s idle.
             Then transfer file in ahci device connected by tbt, ahci should in D0.
             After 30s later should be back in D3 too.

14-13 TBT_XS_FUNC_RTD3_S4_test
      Steps: Check host controller was in D3 mode, and then s4 sleep,
             after wake up and wait 8s, Controller should in D3 again.


Part 15 - TBT SW CM tests:
Set TBT SW CM mode on TBT AIC board.
Command sample:"./runtests.sh -p cfl-s_cnl-h -P cfl-s_cnl-h -f ddt_intel/tbt_none_tests -o /opt/logs/tbt -c"
Command sample:"./runtests.sh -p cfl-s_cnl-h -P cfl-s_cnl-h -f ddt_intel/tbt_user_tests -o /opt/logs/tbt -c"
15-1  TBT_XS_FUNC_USER_MODE_TEST tbt_func_test.sh -s user
      Steps: Security was set user, check tbt device connected,
             set authorized to 1 successfully.

15-2  TBT_XS_FUNC_MONITOR_USER_TEST tbt_func_test.sh -s monitor_user
      Steps: Find tbt 5K monitor in user mode, and set 1 in authorized, and return success.

15-3  TBT_XS_FUNC_USER_PLUG_OUT_TEST tbt_func_test.sh -s po
      Steps: Check tbt devices connected and set user mode, then plug out all tbt devices,
             30s later, check no tbt router like 0-1 folder exist in sysfs.

15-4  TBT_XS_FUNC_USER_PLUG_IN_CHECK tbt_func_test.sh -s upic
      Steps: In user mode, check tbt devices connected, check all tbt router folders exist
             in sysfs files /sys/bus/thunderbolt/devices, all tbt router authorized should
             set 0.

15-5  TBT_XS_FUNC_USER_PLUG_IN_ERROR_CHECK tbt_func_test.sh -s upie
      Steps: In user mode, check tbt devices connected, fill in invalid string in
             authorized, all these action should reject.

15-6  TBT_XS_FUNC_USER_PLUG_IN_ACC_CHECK tbt_func_test.sh -s upiac
      Steps: In user mode, check tbt devices connected, set 1 to authorized, should return
             success, check lspci should contain thunderbolt.

15-7  TBT_XS_FUNC_USER_PLUG_IN_ACC_ERROR tbt_func_test.sh -s upiae
      Steps: In user mode, check tbt devices connected, all tbt router authorized set 1,
             fill in invalid string in authorized, should reject.

15-8  TBT SW CM 2DP tunnel tests
	  Steps: Connect 2 DP monitor on TR SV HR cards, both could display
	  
15-9  TBT SW CM 3 DP tunnels tests
	  Steps: Connect 2 DP monitor on TR SV HR cards, both could display, connected 3rd DP
	  monitor, which could not display, when plugged out 1st one, 3rd could display
	  
15-10 TBT SW CM upgrade test:
	  Steps: upgrade TR AIC from TR_HR_4C_C1_rev41_pre4_Native_RTD3_VHPD_W_TI_6p59_NOSEC_sign#2_AIC_CM_DIS.bin
	  to TR_HR_4C_C1_rev41_preFF_Native_RTD3_VHPD_W_TI_6p59_NOSEC_sign#2_AIC_CM_DIS.bin without issue.

15-11 TBT SW TBT DEVICE CM LINK_SPEED test:
	  Steps: check /sys/bus/thunderbolt/devices/x-x/link_speed exist and should be 10 Gb/s or 20 Gb/s
	  
15-12 TBT SW CM TBT DEVICE LINK_WIDTH test:
	  Steps: cehck /sys/bus/thunderbolt/devices/x-x/link_width exist and should be 1 or 2