#!/bin/bash

systemctl disable bolt.service 2>/dev/null
systemctl stop  bolt.service 2>/dev/null
systemctl status  bolt.service
mv /usr/lib/systemd/system/bolt.service   /root
mv /usr/libexec/boltd   /root
ps -ef | grep bolt
