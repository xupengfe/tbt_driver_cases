#!/bin/sh
home="/home/xpf"

rm -rf $home/DDT/*
sleep 1
cd $home/otc_kernel_qa-ts_ltp_ddt
make autotools
sleep 1
mkdir $home/DDT
$home/otc_kernel_qa-ts_ltp_ddt/configure --prefix="$home/DDT" --with-open-posix-testsuite
sleep 1
make KERNEL_INC="/lib/modules/$(uname -r)/build/include"
sleep 1
make SKIP_IDCHECK=1 install
cd $home/DDT
./install
