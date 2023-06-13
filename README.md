# Authorize and show tbt devices automatically:
```
./verify_tbt_sysfs.sh
...
0-1 contains 0 tbt devices.
0-3 contains 1 tbt devices.
device_topo: USB4 Host Router <-> ThinkPad Thunderbolt 3 Dock
file_topo  : 0-0              <-> 0-3
```


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
