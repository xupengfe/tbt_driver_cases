###############################################################################
##                                                                           ##
## Copyright (c) 2017, Intel Corporation.                                    ##
##                                                                           ##
## This program is free software; you can redistribute it and/or modify it   ##
## under the terms and conditions of the GNU General Public License,         ##
## version 2, as published by the Free Software Foundation.                  ##
##                                                                           ##
## This program is distributed in the hope it will be useful, but WITHOUT    ##
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or     ##
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for ##
## more details.                                                             ##
###############################################################################

# MakeFile function     :: MakeFile for tbt test suite


USBACCESSFILES = USBaccessBasic.o USBaccess.o

# We don't want to copy over the Makefile
UNWANTED_FILES          := Makefile USBaccessBasic.c USBaccess.cpp cleware.cpp \
                           USBaccess.h USBaccessBasic.h cleware.o USBaccess.o \
                           USBaccessBasic.o

INSTALL_MODE            := 00755


CXX = g++

MAKE_TARGETS  := cleware

cleware:
	$(CC) -g -DCLEWARELINUX -c USBaccessBasic.c -o USBaccessBasic.o
	$(CXX) -g -DCLEWARELINUX -c USBaccess.cpp -o USBaccess.o
	$(CXX) -g -DCLEWARELINUX -c cleware.cpp -o cleware.o
	$(CXX) -g $(USBACCESSFILES) cleware.o -o cleware

clean:
	rm *.o cleware
