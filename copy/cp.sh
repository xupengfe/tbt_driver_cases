#!/bin/bash

file_ori="/root/10G_random"
file_tar="/nvme1/10G_random_cp_target"
test_log="./test.log"

cat /dev/null > $test_log

for((i=1;;i++)); do
  echo "$(date)*******Execute $i loops*******"
  echo "$(date)*******Execute $i loops*******" >> $test_log
  echo "cp -rf $file_ori $file_tar"
  echo "cp -rf $file_ori $file_tar" >> $test_log
  cp -rf $file_ori $file_tar

  #rm -rf $file_ori
  echo "cp -rf $file_tar ${file_ori}_cp_bak"
  echo "cp -rf $file_tar ${file_ori}_cp_bak" >> $test_log
  cp -rf $file_tar ${file_ori}_cp_bak
  
  echo "rm -rf $file_tar"
  rm -rf $file_tar
  echo "rm -rf ${file_ori}_bak"
  rm -rf ${file_ori}_bak
done
