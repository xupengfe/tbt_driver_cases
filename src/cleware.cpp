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

int main(int argc, char* argv[]) {
	CUSBaccess CWusb;

	printf("Start USB Access Beispiel!\n");
	printf("argc=%d,argv[1][0]=%c\n",argc,argv[1][0]);
	int USBcount = CWusb.OpenCleware();
	printf("OpenCleware %d USBcount\n", USBcount);

	for (int devID=0; devID < USBcount; devID++) {
		int devType = CWusb.GetUSBType(devID);
		printf("Device %d: Type=%d, Version=%d, SerNum=%d\n", devID,
					devType, CWusb.GetVersion(devID),
					CWusb.GetSerialNumber(devID));
		printf("argc=%d\n", argc);
		if (argc == 2) {
			if (devType == CUSBaccess::SWITCH1_DEVICE) {
				printf("argv=%c <0x%02x>\n", argv[1][0], argv[1][0]);
				printf("old switch setting = %d\n",
						CWusb.GetSwitch(devID, CUSBaccess::SWITCH_0));
				if (argv[1][0] == '0')
					CWusb.SetSwitch(devID, CUSBaccess::SWITCH_0, 0);
				else if (argv[1][0] == '1')
					CWusb.SetSwitch(devID, CUSBaccess::SWITCH_0, 1);
				else {
					printf("False Argument for cleware\n");
					printf("./cleware 1 to power on, 0 to power off\n");
				}
				break;
			}
			else
				continue;		// die anderen Interessieren uns nicht
		}

		if (devType == CUSBaccess::TEMPERATURE_DEVICE || devType == CUSBaccess::TEMPERATURE2_DEVICE) {
			CWusb.ResetDevice(devID);
			usleep(300*1000);		// etwas warten

			// nun 10 Messwerte abfrage
			for (int cnt=0; cnt < 10; cnt++) {
				double temperatur;
				int	   zeit;
				if (!CWusb.GetTemperature(devID, &temperatur, &zeit)) {
					printf("GetTemperature(%d) fehlgeschlagen\n", devID);
					break;
				}
				printf("Messwert %lf Grad Celsius, Zeit = %d\n", temperatur, zeit);
				usleep(1200 * 1000);
			}
		}
		if (devType == CUSBaccess::HUMIDITY1_DEVICE) {
			CWusb.ResetDevice(devID);
			usleep(100*1000);		// etwas warten

			CWusb.StartDevice(devID);
			usleep(300*1000);		// etwas warten
			// nun 10 Messwerte abfrage
			for (int cnt=0; cnt < 10; cnt++) {
				double temperatur, humidity;
				int	   zeit;
				if (!CWusb.GetTemperature(devID, &temperatur, &zeit))
					printf("GetTemperature(%d) fehlgeschlagen\n", devID);
				else
					printf("Messwert %lf Grad Celsius, Zeit = %d\n", temperatur, zeit);
				if (!CWusb.GetHumidity(devID, &humidity, &zeit))
					printf("GetHumidity(%d) fehlgeschlagen\n", devID);
				else
					printf("Messwert %lf %% RH, Zeit = %d\n", humidity, zeit);
				usleep(1200 * 1000);
			}
		}
	}

	CWusb.CloseCleware();

	return 0;
}
