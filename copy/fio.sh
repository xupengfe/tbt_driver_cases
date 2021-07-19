#!/bin/bash


for((i=1;;i++)); do
echo "******$i loops******"
fio -filename=/dev/sda -direct=1 -iodepth 1 -thread -rw=randrw -ioengine=psync -bs=16k -size=200G -numjobs=30 -runtime=1000 -group_reporting -name=mytest
done
