#!/bin/bash

tbt_bios="/root/tbt_driver_cases/bios_tbt/"
tbt_service="/etc/systemd/system/tbtxml.service"


[[ -d "$tbt_bios" ]] || {
  echo "No $tbt_bios folder, please in /root and use root user: git clone https://github.com/xupengfe/tbt_driver_cases.git"
  exit 1
}

ln -s /root/tbt_driver_cases/bios_tbt/bios-tbt.py /usr/bin/bios-tbt.py

echo "[Service]" > $tbt_service
echo "Type=simple" >> $tbt_service
echo "ExecStart=/root/tbt_driver_cases/boot_tbt_xml.sh" >> $tbt_service
echo "[Install]" >> $tbt_service
echo "WantedBy=multi-user.target graphical.target" >> $tbt_service

sleep 1

systemctl daemon-reload
systemctl enable tbtxml
systemctl start tbtxml

systemctl status tbtxml   
