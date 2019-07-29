#!/bin/bash

#cat  read_*.CSV
#cat  write_*.CSV
eval "t=($(nmcli device | grep ethernet | awk '{print $1}' | xargs))"; for i in ${t[@]}; do sudo ifconfig $i up; done;
