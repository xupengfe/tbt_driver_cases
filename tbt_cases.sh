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
2-1   TBT_XS_FUNC_NONE_MODE_TEST tbt_func_test.sh -s none
      Steps: Security was set none, check tbt device connected,
             all authorized should set 1.

2-2   TBT_XS_FUNC_USER_MODE_TEST tbt_func_test.sh -s user
      Steps: Security was set user, check tbt device connected,
             set authorized to 1 successfully.

2-3   TBT_XS_FUNC_SECURE_MODE_WRONG tbt_func_test.sh -s secure_wrong
      Steps: Security was set secure, check tbt device connected,
             set wrong key in sysfs key, and fill 2 to authorized try to approve,
             which should be rejected due to wrong key, otherwise case will be failed.

2-4   TBT_XS_FUNC_SECURE_MODE_VERIFY tbt_func_test.sh -s secure_verify
      Steps: Security was set secure, check tbt device connected,
             set new key in sysfs key, and fill 1 to authorized try to update key
             and approve, which should return success.

2-5   TBT_XS_FUNC_DPONLY_MODE_TEST tbt_func_test.sh -s dp
      Steps: Security was set dponly, check tbt device connected,
             set 1 to authorized file, and no usb and sata connected by tbt find.

2-6   TBT_XS_FUNC_RW_TBT_SSD_10M tbt_ssd_read_write.sh -b 1MB -c 10 -p ssd -t 10
      Steps: Except dponly mode, check tbt device connected,
             find ssd connected with tbt, transfer one 10M file into ssd by dd,
             transfer the 10M file in ssd to platform, and compare the 10M file
             should be same.

2-7   TBT_XS_FUNC_RW_TBT_SSD_100M tbt_ssd_read_write.sh -b 1MB -c 100 -p ssd -t 10
      Steps: Except dponly mode, check tbt device connected,
             find ssd connected with tbt, transfer one 100M file into ssd by dd,
             transfer the 100M file in ssd to platform, and compare the 100M file
             should be same.

2-8   TBT_XS_FUNC_RW_TBT_SSD_500M tbt_ssd_read_write.sh -b 10MB -c 50 -p ssd -t 5
      Steps: Except dponly mode, check tbt device connected,
             find ssd connected with tbt, transfer one 500M file into ssd by dd,
             transfer the 500M file in ssd to platform, and compare the 500M file
             should be same.

2-9   TBT_XS_FUNC_RW_TBT_SSD_1000M tbt_ssd_read_write.sh -b 10MB -c 100 -p ssd -t 5
      Steps: Except dponly mode, check tbt device connected,
             find ssd connected with tbt, transfer one 1000M file into ssd by dd,
             transfer the 1000M file in ssd to platform, and compare the 1000M file
             should be same.

2-10  TBT_XS_FUNC_RW_2.0_FLASH tbt_ssd_read_write.sh -b 1MB -c 100 -p 2.0 -d flash -t 2
      Steps: Except dponly mode, check tbt device connected,
             find usb2.0 connected with tbt, transfer one 100M file into usb2.0 by dd,
             transfer the 100M file from usb2.0 to platform, and compare the 100M file
             should be same.

2-11  TBT_XS_FUNC_RW_3.0_FLASH tbt_ssd_read_write.sh -b 1MB -c 100 -p 3.0 -d flash -t 2
      Steps: Except dponly mode, check tbt device connected,
             find usb3.0 connected with tbt, transfer one 100M file into usb3.0 by dd,
             transfer the 100M file from usb3.0 to platform, and compare the 100M file
             should be same.

2-12  TBT_XS_FUNC_MONITOR_NONE_TEST tbt_func_test.sh -s monitor_none
      Steps: Find tbt 5K monitor in none mode, and check authorized should set 1.

2-13  TBT_XS_FUNC_MONITOR_USER_TEST tbt_func_test.sh -s monitor_user
      Steps: Find tbt 5K monitor in user mode, and set 1 in authorized, and return success.

2-14  TBT_XS_FUNC_MONITOR_SECURE_TEST tbt_func_test.sh -s monitor_secure
      Steps: Find tbt 5K monitor in secure mode, and verify corrected key, authorized
             should set 2 when correct key is setted, set 1 when correct key is not
             found and update new key.

2-15  TBT_XS_FUNC_MONITOR_DP_TEST tbt_func_test.sh -s monitor_dp
      Steps: Connect tbt 5K monitor, and approve 5K monitor accees,
             check 5K monitor device is recognized.


Part 3 - TBT hotplug function tests:
Command sample: "./runtests.sh -p cfl-h-rvp -P cfl-h-rvp -f ddt_intel/tbt_hotplug_tests -o /opt/logs/tbt_hotplug -c"
3-1   TBT_XS_FUNC_PLUG_OUT_TEST tbt_func_test.sh -s po
      Steps: Check tbt devices connected, then plug out all tbt devices,
             30s later, check no tbt router like 0-1 folder exist in sysfs.

3-2   TBT_XS_FUNC_USER_PLUG_IN_CHECK tbt_func_test.sh -s upic
      Steps: In user mode, check tbt devices connected, check all tbt router folders exist
             in sysfs files /sys/bus/thunderbolt/devices, all tbt router authorized should
             set 0.

3-3   TBT_XS_FUNC_USER_PLUG_IN_ERROR_CHECK tbt_func_test.sh -s upie
      Steps: In user mode, check tbt devices connected, fill in invalid string in
             authorized, all these action should reject.

3-4   TBT_XS_FUNC_USER_PLUG_IN_ACC_CHECK tbt_func_test.sh -s upiac
      Steps: In user mode, check tbt devices connected, set 1 to authorized, should return
             success, check lspci should contain thunderbolt.

3-5   TBT_XS_FUNC_USER_PLUG_IN_ACC_ERROR tbt_func_test.sh -s upiae
      Steps: In user mode, check tbt devices connected, all tbt router authorized set 1,
             fill in invalid string in authorized, should reject.

3-6   TBT_XS_FUNC_SECURE_PLUG_IN_CHECK tbt_func_test.sh -s spic
      Steps: In secure mode, plug in all tbt devices, tbt router authorized should set 0.

3-7   TBT_XS_FUNC_SECURE_PLUG_IN_ERROR_CHECK tbt_func_test.sh -s spie
      Steps: In secure mode, plug in all tbt devices, input invalid string in authorized,
             all these actions return fail.

3-8   TBT_XS_FUNC_SECURE_PLUG_IN_APPROVE tbt_func_test.sh -s spiaw
      Steps: In secure mode, check tbt devices connected, set 1 into authorized without
             key, return success, and all tbt devices approve to access.

3-9   TBT_XS_FUNC_SECURE_PLUG_IN_UPDATE_KEY tbt_func_test.sh -s spiu
      Steps: In secure mode, plug out all tbt devices, and plug in, set the new key in
             sysfs key, then set 1 into authorized, should return success, and all tbt
             approve to access, and update the new key successfully.

3-10  TBT_XS_FUNC_SECURE_PLUG_IN_VERIFY_KEY tbt_func_test.sh -s spiv
      Steps: In secure mode, plug out all tbt devices, and plug in, set the key last
             time update, set 2 into authorized, should return success, all tbt appove
             to access.

3-11  TBT_XS_FUNC_COMMON_SSD_TRANS_POI tbt_func_test.sh -s po_transfer -p ssd -d device
      Steps: Except dp mode, plug in tbt devices which connected ssd, appove tbt access,
             transfer 500M file into ssd, when transfer file is ongoing, plug out all
             tbt devices, 30s later plug in tbt devices should without issue, and transfer
             500M file in ssd successfully.

3-12  TBT_XS_FUNC_COMMON_USB2.0_TRANS_POI tbt_func_test.sh -s po_transfer -p 2.0 -d flash
      Steps: Except dp mode, plug in tbt devices which connected usb2.0, appove tbt access,
             transfer 500M file into usb2.0, when transfer file is ongoing, plug out all
             tbt devices, 30s later plug in tbt devices should without issue, and transfer
             500M file in 2.0 successfully.

3-13  TBT_XS_FUNC_COMMON_USB3.0_TRANS_POI tbt_func_test.sh -s po_transfer -p 3.0 -d flash
      Steps: Except dp mode, plug in tbt devices which connected usb3.0, appove tbt access,
             transfer 500M file into usb3.0, when transfer file is ongoing, plug out all
             tbt devices, 30s later plug in tbt devices should without issue, and transfer
             500M file in 3.0 successfully.

3-14  TBT_XS_FUNC_COMMON_HOTPLUG_CHECK tbt_func_test.sh -s poi -p 10
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
             /sys/bus/thunderbolt/devices/0-0/nvm_authenticate, set 1 into
             /sys/bus/thunderbolt/devices/0-0/nvm_authenticate to start NVM
             downgrade, after nvm_authenticate changed to 0, check nvm version
             is expected and different than before NVM.

4-2   TBT_XS_FUNC_NVM_UPGRADE tbt_func_test.sh -s nvm_upgrade
      Steps: Save the nvm version before upgrade, copy nvm upgrade file in
             /sys/bus/thunderbolt/devices/0-0/nvm_authenticate, set 1 into
             /sys/bus/thunderbolt/devices/0-0/nvm_authenticate to start NVM
             upgrade, after nvm_authenticate changed to 0, check nvm version
             is expected.


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
