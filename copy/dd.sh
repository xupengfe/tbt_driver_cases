#!/bin/bash

file_ori="/root/10G_random"
file_tar="/nvme1/10G_random_tar"
test_log="./test.log"

cat /dev/null > $test_log

for((i=1;;i++)); do
  echo "$(date)*******Execute $i loops*******"
  echo "$(date)*******Execute $i loops*******" >> $test_log
  echo "dd if=$file_ori of=$file_tar"
  echo "dd if=$file_ori of=$file_tar" >> $test_log
  dd if=$file_ori of=$file_tar

  #rm -rf $file_ori
  echo "dd if=$file_tar of=${file_ori}_bak"
  echo "dd if=$file_tar of=${file_ori}_bak" >> $test_log
  dd if=$file_tar of=${file_ori}_bak
  
  echo "rm -rf $file_tar"
  rm -rf $file_tar
  echo "rm -rf ${file_ori}_bak"
  rm -rf ${file_ori}_bak
done
