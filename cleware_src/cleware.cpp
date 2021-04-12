/*
 * cleware.c
 *
 * Copyright (C) 2018, Intel - http://www.intel.com/
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * Contributors:
 *      - Reference from http://www.cleware.info/data/linux_E.html
 *      - Pengfei, Xu <pengfei.xu@intel.com>
 *      - Add print and format normalize
 */

/*****************************************************************************/

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include "USBaccess.h"


int usage(void)
{
	CUSBaccess CWusb;
	printf("Usage: [0|1] [X]\n");
	printf("Par1:  0 means power off, 1 means power off\n");
	printf("Par2:  0 means 1(1st) connected cleware in hex(max f for cleware 16)\n");
	CWusb.CloseCleware();

	exit(1);
}

int check_status()
{
	CUSBaccess CWshow;
	int id = 0, USBcnt = 0;
	enum CUSBaccess::SWITCH_IDs switchID = CUSBaccess::SWITCH_0;

	USBcnt = CWshow.OpenCleware();
	for (id = 0; id < USBcnt; id++) {
		switchID = (enum CUSBaccess::SWITCH_IDs)(CUSBaccess::SWITCH_0 + id);
		CWshow.GetSwitch(id, switchID);
		printf("Cleware %x power status = %d\n",
				id, CWshow.GetSeqSwitch(id, switchID, 0));
	}
	CWshow.CloseCleware();

	return 0;
}


int main(int argc, char* argv[]) {
	CUSBaccess CWusb;
	int cnt = 0;
	int cle_id = 0, devType, state = 0, devID = 0, USBcount = 0;
	unsigned int switch_id;
	enum CUSBaccess::SWITCH_IDs switchID = CUSBaccess::SWITCH_0;

	USBcount = CWusb.OpenCleware();
	if (argc == 2) {
		printf("Cleware argc=%d,argv[1][0]=%c\n", argc, argv[1][0]);
		if (argv[1][0] == 'h' || argv[1][1] == 'h')
			usage();
	} else if (argc == 3) {
		printf("Cleware argc=%d,argv[1][0]=%c, argv[2]:%s\n",
			argc, argv[1][0], argv[2]);
		sscanf(argv[2], "%x", &cle_id);
		if ((cle_id < 0) || (cle_id >= USBcount)) {
			printf("argv[2]:0x%x is not in cleware max range 0-0x%x present\n", 
				cle_id, USBcount-1);
			usage();
		}
	} else
		usage();

	if (!((argv[1][0] == '0') || (argv[1][0] == '1'))) {
		printf("argv[1][0] is not 0 or 1:%c\n", argv[1][0]);
		usage();
	}

	printf("Open Cleware %d USBcount\n", USBcount);

	printf("***** Before action, cleware ID status is as below *****\n");
	check_status();

	// power off/on specific cleware 0-0xf
	if (argc == 3) {
		USBcount = CWusb.OpenCleware();
		switch_id = 0x10 + cle_id;
		devType = CWusb.GetUSBType(cle_id);
		printf("Device %d: Type=%d, Version=%d, SerNum=%d\n\n", cle_id,
				devType, CWusb.GetVersion(cle_id),
				CWusb.GetSerialNumber(cle_id));
		switchID = (enum CUSBaccess::SWITCH_IDs)(switchID + cle_id);

		if (argv[1][0] == '0') {
			printf("-> Power off Cleware:0x%x\n", cle_id);
			state = CWusb.SetSwitch(cle_id, CUSBaccess::SWITCH_0, 0);
			//usleep(30 * 1000);
			//state =CWusb.SetSwitch(cle_id, CUSBaccess::SWITCH_0, 0);
		} else if (argv[1][0] == '1') {
			printf("-> Power on Cleware:0x%x\n", cle_id);
			state = CWusb.SetSwitch(cle_id, CUSBaccess::SWITCH_0, 1);
			//usleep(30 * 1000);
			//state =CWusb.SetSwitch(cle_id, CUSBaccess::SWITCH_0, 1);
		} else {
			printf("Invalid argv[1][0]:%c not 0 or 1\n", argv[1][0]);
			usage();
		}
	}

	// power off/on only first cleware
	if (argc == 2) {
		USBcount = CWusb.OpenCleware();
		devType = CWusb.GetUSBType(devID);
		printf("Device %d: Type=%d, Version=%d, SerNum=%d\n\n", devID,
				devType, CWusb.GetVersion(devID),
				CWusb.GetSerialNumber(devID));
		if (devType == CUSBaccess::SWITCH1_DEVICE) {
			if (argv[1][0] == '0') {
				printf(" -> Only power OFF first connected cleware\n");
				CWusb.SetSwitch(devID, CUSBaccess::SWITCH_0, 0);
			} else if (argv[1][0] == '1') {
				printf(" -> Only power ON first connected cleware\n");
				CWusb.SetSwitch(devID, CUSBaccess::SWITCH_0, 1);
			} else {
				printf("Invalid argv[1][0] for cleware:%c\n", argv[1][0]);
				printf("./cleware 1 to power on, 0 to power off\n");
			}
		}
	}

	usleep(30 * 1000);
	printf("\n***** After action, cleware ID status is as below *****\n");
	check_status();

	CWusb.CloseCleware();

	return 0;
}
