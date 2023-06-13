# Authorize and show tbt devices automatically:
```
./verify_tbt_sysfs.sh
...
0-1 contains 2 tbt devices.
device_topo: no_name <-> AKiTiO Thunder3 Duo Pro <-> ThinkPad Thunderbolt 3 Dock
file_topo  : 0-0     <-> 0-1                     <-> 0-101
0-3 contains 0 tbt devices.
1-1 contains 0 tbt devices.
1-3 contains 0 tbt devices.

|20230613-111233.433494150|TRACE|Discrete or FW CM on TGLS,root:0000:00:07.0, /sys/devices/pci0000:00/0000:00:07.0|
|20230613-111233.436216796|TRACE|TBT ROOT:0000:00:07.0 SYS_PATH:/sys/devices/pci0000:00/0000:00:07.0|
PF_BIOS: platform, ROOT_PCI:0000:00:07.0
Upstream pci:0000:02:00.0
Upstream pci:0000:06:00.0
0-1:AKiTiO Thunder3 Duo Pro
 |-> /dev/sdb HDD pci-04:00 INTEL_SSDSC2BW080A4_BTDA337402UU0806GN
0-101:ThinkPad Thunderbolt 3 Dock
 |-> /dev/sda USB2.0 pci-08:00 Netac_OnlyDisk_2A9E6BA269ED54332A5F5B92
 |-> /dev/sdc USB3.0 pci-08:00 SanDisk_Cruzer_Glide_3.0_4C530001320801100511
```
## Could use usb4 swich to control 1 USB3/4 device plug or unplug
```
usb4switch: https://mcci.com/usb/dev-tools/model-3141/ 
cd usb4switch3141/
./usb4switch.sh  [1|2|0 or off|s|h|*]
  1    Connect host port to port 1 with super speed
  2    Connect host port to port 2 with super speed
  0|off  Disconned all ports with host port
  s    Check current status
  hot  One round port 1, 2 and disconnect test
  h|*  Show this and show status
```

## Some other tips
---

tbt_cases.sh is just a text file which saved the tbt driver cases.
pdf.sh is a script to generate the pdf for tbt_cases.sh or some other text file.
Thanks Westerberg Mika's advice!
grep -H . /sys/bus/thunderbolt/devices/*/* 2>/dev/null

Refer more information in https://github.com/xupengfe/tbt_driver_cases

Could buy one USB4 device in market by below link for validation:
thunderbolt4 docker https://eshop.macsales.com/shop/owc-thunderbolt-dock
$249

verify_tbt_sysfs.sh:
ls -l /sys/bus/thunderbolt/devices/domain*0 2>/dev/null \
            | grep "-" \
            | grep -v ":" \
            | awk '{ print length(), $0 | "sort -n" }' \
            | tail -n 1 \
            | awk -F "domain0/" '{print $2}' \
            | tr '/' ' '


  ls -l /sys/bus/thunderbolt/devices/domain*0  2>/dev/null \
    | grep "-" \
    | awk -F "domain0" '{print $2}' \
    | awk '{ print length(), $0 | "sort -n" }' \
    | cut -d ' ' -f 2 \
    | tr '/' ' '



domains
ls /sys/bus/thunderbolt/devices/ \
            | grep "domain" \
            | grep -v ":" \
            | awk -F "domain" '{print $2}' \
            | awk -F "->" '{print $1}'



tbt_sys_file
  ls -l /sys/bus/thunderbolt/devices/1*3 2>/dev/null \
    | grep "-" \
    | awk -F "domain1/" '{print $2}' \
    | awk '{ print length(), $0 | "sort -n" }' \
	| grep -v ":" \
    | cut -d ' ' -f 2 \
    | tr '/' ' '
1-0 1-3
1-0 1-3 1-303
1-0 1-3 1-303 1-10303


  ls -l /sys/bus/thunderbolt/devices/1*1 2>/dev/null \
    | grep "-" \
    | awk -F "domain1/" '{print $2}'


  ls -l /sys/bus/thunderbolt/devices/1*3 2>/dev/null \
    | grep "-" \
	| grep -v ":" \
    | awk -F "domain1/" '{print $2}' \
    | awk '{ print length(), $0 | "sort -n" }' \
    | cut -d ' ' -f 2 \
    | tr '/' ' '

  ls -l /sys/bus/thunderbolt/devices/1*1 2>/dev/null \
    | grep "-" \
    | awk -F "domain1/" '{print $2}' \
    | awk '{ print length(), $0 | "sort -n" }' \
    | cut -d ' ' -f 2 \
    | tr '/' ' '
1-0 usb4_port3 1-0:3.1

so need to add  " grep -v ":"  | grep -v "_"     "



tbt_devs
ls /sys/bus/thunderbolt/devices/ 2>/dev/null \
    | grep "-" \
    | grep "^1" \
    | grep "3$" \
    | awk '{ print length(), $0 | "sort -n" }' \
    | cut -d ' ' -f 2
1-3
1-303
1-10303


ls /sys/bus/thunderbolt/devices/ 2>/dev/null \
    | grep "-" \
    | grep -v ":" \
    | grep "^1" \
    | grep "1$" \
    | awk '{ print length(), $0 | "sort -n" }' \
    | cut -d ' ' -f 2


ls /sys/bus/thunderbolt/devices/ 2>/dev/null \
    | grep "-" \
    | grep -v ":" \
    | grep "^1" \
    | grep "3$" \
    | awk '{ print length(), $0 | "sort -n" }' \
    | cut -d ' ' -f 2



device_num
ls /sys/bus/thunderbolt/devices/ \
    | grep "^1" \
    | grep "3$" \
    | wc -l



dr_pci_h
udevadm info -q path --path=/sys/bus/thunderbolt/devices/domain1 \
            | awk -F "/" '{print $(NF-1)}' \
            | cut -d ':' -f 3


ls /sys/bus/thunderbolt/devices/ \
              | grep "-" \
              | grep -v "\-0" \
              | grep -v ":" \
              | awk '{ print length(), $0 | "sort -n" }' \
              | cut -d ' ' -f 2 \
              | head -n1

  # get like 1-3
  tbt_dev=$(ls ${TBT_PATH} \
              | grep "$REGEX_DEVICE" \
              | grep -v "$HOST_EXCLUDE" \
              | grep -v ":" \
              | awk '{ print length(), $0 | "sort -n" }' \
              | cut -d ' ' -f 2 \
              | head -n1)



udevadm info --attribute-walk --path=/sys/bus/thunderbolt/devices/1-3 | grep KERNEL | tail -n 2 | grep -v pci0000 | cut -d "\"" -f 2


# ls -1 /sys/bus/pci/devices
0000:00:00.0
0000:00:02.0
0000:00:04.0
0000:00:06.0
0000:00:07.0
0000:00:07.1
0000:00:07.2
0000:00:07.3
0000:00:08.0
0000:00:0a.0
0000:00:0d.0
0000:00:0d.2
0000:00:0d.3
0000:00:14.0
0000:00:14.2
0000:00:15.0
0000:00:15.1
0000:00:15.2
0000:00:15.3
0000:00:16.0
0000:00:17.0
0000:00:19.0
0000:00:19.1
0000:00:1e.0
0000:00:1e.3
0000:00:1f.0
0000:00:1f.4
0000:00:1f.5
0000:00:1f.6
0000:01:00.0


Could test some file transfer basic function tests under USB2/3.0 connected with USB4 docker.
