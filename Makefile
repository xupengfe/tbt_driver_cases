#
# MakeFile function     :: MakeFile for tbt cleware
# Copyright (C) 2018 Intel Corporation
# Author: Pengfei, Xu <pengfei.xu@intel.com>
#

CC = gcc
CXX = g++
USBACCESSFILES = USBaccessBasic.o USBaccess.o

BIN = cleware pcie_check

all: $(BIN)

cleware:
	$(CC) -g -DCLEWARELINUX -c src/USBaccessBasic.c -o USBaccessBasic.o
	$(CXX) -g -DCLEWARELINUX -c src/USBaccess.cpp -o USBaccess.o
	$(CXX) -g -DCLEWARELINUX -c src/cleware.cpp -o cleware.o
	$(CXX) -g $(USBACCESSFILES) cleware.o -o cleware

pcie_check:
	$(CC) -o pcie_check pcie_check.c

clean:
	rm -rf *.o cleware
