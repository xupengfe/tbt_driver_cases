ln -s /root/tbt_driver_cases/bios_tbt/bios-tbt.py /usr/bin/bios-tbt.py



python2.7
import sys
sys.path.append(r"/root/xmlcli/")
import XmlCli as cli
cli.clb._setCliAccess("linux")
cli.clb.ConfXmlCli()

>>>
>>> MyKnobsDict={}
>>> cli.savexml()
CLI Spec Version = 0.7.1
Compressed XML is not supported, Downloading Regular XML
Host XML didnt exist or is different from Target XML, downloading Target XML..
Saved XML Data as /root/xmlcli/out/PlatformConfig.xml
0
>>> cli.prs.EvalKnobsDepex(r"/root/xmlcli/out/PlatformConfig.xml",MyKnobsDict,"/root/Dep1.csv")
Parsing Xml File /root/xmlcli/out/PlatformConfig.xml
generated csv file /root/Dep1.csv
0
>>> MyKnobsDict['SecurityMode']['Depex']
'Sif( TbtSetupFormSupport _NEQ_ 1 ) _AND_ Sif( DiscreteTbtSupport _EQU_ 0  )'
>>>




1.	Get current XML file,  and XML file was saved in /bios_xml_path/target.xml
Command:
bios_set.py -g current
		Output:
		Last line: /bios_xml_path/target.xml

2.	Recovered default BIOS setting, and saved default XML,  default XML file was saved in /root/target.xml
Command:
bios_set.py -g default
	Output:
		Last line: /bios_xml_path/target.xml


3.	Set BIOS items into present BIOS, and saved final XML file in /bios_xml_path/target.xml
Command:
bios_set.py -s "DiscreteTbtSupport=0x1,TbtBootOn=0x2,TBTHotSMI=0x0,Gpio5Filter=0x0,TBTHotNotify=0x0,DTbtController_0=0x1,TBTSetClkReq=0x1,TbtLtr=0x1,DTbthostRouterPortNumber_0=0x2,DTbtPcieExtraBusRsvd_0=0x6A,DTbtPcieMemRsvd_0=0x6A,DTbtPcieMemRsvd_0=0x2E1,DTbtPciePMemRsvd_0=0x4A0,Win10Support=0x2,TrOsup=0x1,TbtL1SubStates=0x0,Rtd3Tbt=0x1,TbtVtdBaseSecurity=0x1,EnableSgx=0x1,PrmrrSize=0x8000000,EnableAbove4GBMmio=0x1,PrimaryDisplay_inst_3=0x0,PcieRootPortAspm_20=0x2,PcieRootPortHPE_20=0x1,PcieRootPortDptp_20=0x5,PcieSwEqOverride=0x1"
         	Output:
		Second last line: /bios_xml_path/target.xml
		Last line: /bios_xml_path/out/TmpBiosKnobs.ini


4.	Set BIOS as default setting first,  and then set BIOS items, and saved final XML file in /root/target.xml
Command:
bios_set.py -d "DiscreteTbtSupport=0x1,TbtBootOn=0x2,TBTHotSMI=0x0,Gpio5Filter=0x0,TBTHotNotify=0x0,DTbtController_0=0x1,TBTSetClkReq=0x1,TbtLtr=0x1,DTbthostRouterPortNumber_0=0x2,DTbtPcieExtraBusRsvd_0=0x6A,DTbtPcieMemRsvd_0=0x6A,DTbtPcieMemRsvd_0=0x2E1,DTbtPciePMemRsvd_0=0x4A0,Win10Support=0x2,TrOsup=0x1,TbtL1SubStates=0x0,Rtd3Tbt=0x1,TbtVtdBaseSecurity=0x1,EnableSgx=0x1,PrmrrSize=0x8000000,EnableAbove4GBMmio=0x1,PrimaryDisplay_inst_3=0x0,PcieRootPortAspm_20=0x2,PcieRootPortHPE_20=0x1,PcieRootPortDptp_20=0x5,PcieSwEqOverride=0x1"
		Second last line: /bios_xml_path/target.xml
		Last line: /bios_xml_path/out/TmpBiosKnobs.ini

5. 	Set ini file into BIOS
	bios_set.py -i ini_file_path
	Set ini file
	Output:
	Last line: /bios_xml_path/target.xml



-------------------------------------------------------------------------------------------------------------
XmlCli Reference scripts which are based on XML Information & BIOS CLI interface protocol.
These Ref. scripts provides several capabilities such as Programming/Reading BIOS knobs,
Fetching Platform XML from target, Flashing BIOS, Fetching BIOS, Ucode read, Save & Update,
System Information, etc. These scripts are generic and platform/program independent
(as long as the BIOS on SUT BIOS supports XML CLI interface).
The scripts were tested on SVOS, ITP DAL & on systems with SV HIF card.
These scripts can be updated to work on Windows & Linux SUT's.
This check-in is the V 1.0 check-in tested across several different platforms and test enviornments.
Please let me (ashinde) know for any querries or feedback related to these scripts/interface.
let me know for more questions/clarification (amol.shinde@intel.com)
-------------------------------------------------------------------------------------------------------------

Supported Interface Types:
	Legacy ITP
	ITP II
	Lauterbac
	DCI
	Simics
	SVOS
	Windows
	LINUX
	EFI Shell
	SV HIF card
	TSSA
	Offline mode (or stub mode, to enable BIOS/IFWI Editing)


Prerequisites:
	Python 2.7 S/W installed on the system.
	For running it on Windows SUT, you need to install CCB SDK (for HWAPI interface)

Common importing steps:
	Copy the Reference scripts on any folder on the system
	open Python Prompt and run following commands
		import sys
		sys.path.append(r"<Path_To_XmlCliRefScripts>")
		import XmlCli as cli

Setting Interface Type:
	Need to select the interface to indicate the scripts on which access method to use (depending on which enviournment we expect the script to operate in).
		cli.clb._setCliAccess("itpii")		# For using ITPII as interface, need to have ITP S/W & H/W installed on the system
		cli.clb._setCliAccess("svlegitp")	# For using Legacy ITP as interface, need to have Legacy ITP S/W & H/W installed on the system
		cli.clb._setCliAccess("ltb")		# For using Lauterbac as interface, need to have LTB S/W & H/W installed on the system
		cli.clb._setCliAccess("dci")		# For using dci as interface, need to have ITP & DCI S/W & H/W installed on the system
		cli.clb._setCliAccess("simics")		# For using simics as interface (Pre-Silicon), need to have simics S/W installed on the system. BKM for enabling this in under \Misc\BKM_to_Enable_PyDev_ITPii_and_ XmlCli_in_Simics.docx
		cli.clb._setCliAccess("svos")		# For using svos as interface, need to have svos disk installed on the system
		cli.clb._setCliAccess("winssa")		# For using ssa as primary interface on Windows (recomended, uses HWAPI DLL), need to have SSA folder copied under C:\Python27\Lib\site-packages\  SSA folder can be unzipped from \\bascrd101\svshare\Amol\XmlCliRefScripts\ssa.zip
		cli.clb._setCliAccess("winsdk")		# For using SDK as Windows interface (uses HWAPI DLL), need to have "Intel® CCG Platform Tools SDK" installed on the system.
							# Find the SDK from \\bascrd101\svshare\amol\XmlCliRefScripts\Intel® CCG Platform Tools SDK.zip
							# Latest SDK that fixes the BSOD is under \\bascrd101\svshare\Amol\XmlCliRefScripts\CCBSDK_1.2.1002.zip
		cli.clb._setCliAccess("winrwe")		# For using RW.exe as Windows interface (slow, least recomended)
		cli.clb._setCliAccess("linux")		# For using linux as interface, need to open Python Prompt in root permissions.
		cli.clb._setCliAccess("uefi")		# For using EFI SHELL as interface, need to have EFI SHELL's Python Interpretor on the system
		cli.clb._setCliAccess("svhif")		# For using SV Host Interface Card (Dishon, Kfir) as interface, need to have Sv HIF card plugged on the system and Sv Mode innitialized.
		cli.clb._setCliAccess("tssa")		# For using Windows, Mac & Linux as Interface, need to have SSA pkg installed that suppport baseaccess python wrapper.

Running popular comands:
	After initializing the desired interface, the use may run following commands.
	If the commands return 0, it means the operation was successfull, else there was an error.

	Std import steps:
		import sys
		sys.path.append(r"<Path_To_XmlCliRefScripts>")
		import XmlCli as cli
		cli.clb._setCliAccess("itpii")		# Set desired Interface (for example itpii)

	# Step to check XmlCli capability on current System, Please ensure to rename the EnableXmlCli.pyc_ under xmlcli\tools folder back to EnableXmlCli.pyc
		cli.clb.ConfXmlCli()	# Check if XmlCli is supported &/ Enabled on the current system.
					# If it returns Value 0 it means XmlCli is already supported & enabled.
					# If it returns value 2 then it means XmlCli is supported but was not enabled, the script has now enabled it and SUT needs reboot to make use of XmlCli.
					# If it returns value 1 then it means XmlCli is not supported on the current BIOS or the System BIOS has not completed Boot.


	# To Save Target XML file
		cli.savexml()					# Save Target XML as <Path_To_XmlCliRefScripts>\out\PlatformConfig.xml File.
		cli.savexml(r"<MyFilePath>")	# Save Target XML as <MyFilePath> File.
		cli.savexml(0, r"<MyBIOS_or_IFWI_FilePath>")	# Extract the XML data from desired BIOS or IFWI binary. Will Save Target XML in <Path_To_XmlCliRefScripts>\out folder.
		cli.savexml(r"<MyFilePath>", r"<MyBIOS_or_IFWI_FilePath>")	# Extract the XML data from desired BIOS or IFWI binary. Will Save Target XML as <MyFilePath>.


	# To Read BIOS settings, for Online command to run successfully, the target must complet BIOS boot.
	# For Offline mode, you need to pass the link to BIOS or IFWI binary.
	# Knob_A & Knob_B in the below examples are the knob names tken from the "name" atribute from the <biosknobs> section in the XML, its case sensitive.
		cli.CvReadKnobs("Knob_A=Val_1, Knobs_B=Val_2")		# Reads the desired Knob_A & Knob_B settings from the SUT and verifies them against Val_1 & Val_2 respectively.
		cli.CvReadKnobs()		# same as above, just that the Knob entires will be read from the default cfg file (<Path_To_XmlCliRefScripts>\cfg\BiosKnobs.ini).
		# the default cfg file pointer can be programed to desired cfg file via following command.
			cli.clb.KnobsIniFile = r"<MyCfgFilePath>"
		cli.CvReadKnobs("Knob_A=Val_1, Knobs_B=Val_2", r"<MyBIOS_or_IFWI_FilePath>")	# Reads & verifies the desired knob settings from the given BIOS or IFWI binary.
		cli.CvReadKnobs(0, r"<MyBIOS_or_IFWI_FilePath>")		# same as above, just that the Knob entires will be read from the cli.clb.KnobsIniFile cfg file instead.


	# To Prog BIOS settings, for Online command to run successfully, the target must complet BIOS boot.
	# For Offline mode, you need to pass the link to BIOS or IFWI binary.
	# Knob_A & Knob_B in the below examples are the knob names tken from the "name" atribute from the <biosknobs> section in the XML, its case sensitive.
		cli.CvProgKnobs("Knob_A=Val_1, Knobs_B=Val_2")		# Programs the desired Knob_A & Knob_B settings on the SUT and verifies them against Val_1 & Val_2 respectively.
		cli.CvProgKnobs()		# same as above, just that the Knob entires will be Programed from the default cfg file (<Path_To_XmlCliRefScripts>\cfg\BiosKnobs.ini).
		# the default cfg file pointer can be programed to desired cfg file via following command.
			cli.clb.KnobsIniFile = r"<MyCfgFilePath>"
		cli.CvProgKnobs("Knob_A=Val_1, Knobs_B=Val_2", r"<MyBIOS_or_IFWI_FilePath>")	# Prog the desired knob settings as new default value, operates on BIOS or IFWI binary, new BIOS or IFWI binary will be generated with desired settings.
		cli.CvProgKnobs(0, r"<MyBIOS_or_IFWI_FilePath>")		# same as above, just that the Knob entires will be Programed from the cli.clb.KnobsIniFile cfg file instead.


	# To Load Defualt BIOS settings on the SUT. Offline mode not supported or not Applicable.
		cli.CvLoadDefaults()	# Loads/Restroes the default value back on the system, also shows which values were restored back to its default Value.


	# To Prog only desired BIOS settings and reverting rest all settings back to its defaut value. Offline mode not supported or not Applicable.
	# Knob_A & Knob_B in the below examples are the knob names tken from the "name" atribute from the <biosknobs> section in the XML, its case sensitive.
		cli.CvRestoreModifyKnobs("Knob_A=Val_1, Knobs_B=Val_2")		# Programs the desired Knob_A & Knob_B settings and restores everything else back to its default value.
		cli.CvRestoreModifyKnobs()		# same as above, just that the Knob entires will be Programed from the cli.clb.KnobsIniFile cfg file instead.


	# Process Ucode operation, For Offline mode, you need to pass the link to BIOS or IFWI binary.
		cli.ProcessUcode()		# Online mode, Operates on SUT, by default reads the current Ucode entries.
		cli.ProcessUcode("read", r"<MyBIOS_or_IFWI_FilePath>")		# Offline mode, Operates on given BIOS or IFWI binary file, read the current Ucode entries.

		cli.ProcessUcode("update", 0, r"<Desired_Ucode_File>")		# Online mode, Operates on SUT, Updates the desired Patch file (.inc or .pdb format) on the target system.
		cli.ProcessUcode("update", r"<MyBIOS_or_IFWI_FilePath>, r"<Desired_Ucode_File>")	# Offline mode, same as above except that it Operates on given BIOS or IFWI binary file, new BIOS/IFWI binary will be generated.

		cli.ProcessUcode("save", ReqCpuId=0x<CpuIdVal>)		# Online mode, Saves the Ucode data as a file for given CpuId entry under <Path_To_XmlCliRefScripts>\out folder.
		cli.ProcessUcode("save", r"<MyBIOS_or_IFWI_FilePath>, ReqCpuId=0x<CpuIdVal>")	# Offline mode, same as above except that it Operates on given BIOS or IFWI binary file, new BIOS/IFWI binary will be generated.

		cli.ProcessUcode("saveall")		# Online mode, Saves the Ucode data as a file for all entries under <Path_To_XmlCliRefScripts>\out folder.
		cli.ProcessUcode("saveall", r"<MyBIOS_or_IFWI_FilePath>")	# Offline mode, same as above except that it Operates on given BIOS or IFWI binary file, new BIOS/IFWI binary will be generated.

		cli.ProcessUcode("delete", ReqCpuId=0x<CpuIdVal>)								# Online mode, Deletes the Ucode entry for given CpuId entry.
		cli.ProcessUcode("delete", r"<MyBIOS_or_IFWI_FilePath>, ReqCpuId=0x<CpuIdVal>")	# Offline mode, same as above except that it Operates on given BIOS or IFWI binary file, new BIOS/IFWI binary will be generated.

		cli.ProcessUcode("deleteall")	# Online mode, Deletes all the Ucode entries.
		cli.ProcessUcode("deleteall", r"<MyBIOS_or_IFWI_FilePath>, ReqCpuId=0x<CpuIdVal>")	# Offline mode, same as above except that it Operates on given BIOS or IFWI binary file, new BIOS/IFWI binary will be generated.

		cli.ProcessUcode("fixfit")		# Online mode, Operates on SUT, Verifies FIT, and if FIT table was wrong, fixes it.
		cli.ProcessUcode("fixfit", r"<MyBIOS_or_IFWI_FilePath>")		# Offline mode, same as above except that it Operates on given BIOS or IFWI binary file, new BIOS/IFWI binary will be generated.


	# SPI Flash Read/Write: Run following Commands to enable Flashing support. Please note BIOS needs to support Flash update XmlCli API's for this to work.
		cli.CvProgKnobs("PchRtcLock=0,FlashWearOutProtection=0,BiosGuard=0,FprrEnable=0,PchBiosLock=0")
		# The above is required to be able to enable SPI Flashing support on CCG BIOS
		# Reboot the system.
		# After running this confirm that the settings are set correctly, by running following command
		cli.CvReadKnobs("PchRtcLock=0,FlashWearOutProtection=0,BiosGuard=0,FprrEnable=0,PchBiosLock=0")
		# The above command should return 0 (0 = Success).

		# For flashing the SPI run one of following commands (see example below).
		cli.SpiFlash('write', r"C:\SVShare\Amol\XmlCli\KBL\Amol\Prod_KBLX098_01.rom", cli.fwp.BIOS_Region)		# to Flash BIOS only Region
		cli.SpiFlash('write', r"C:\SVShare\Amol\XmlCli\KBL\Amol\ME.bin", cli.fwp.ME_Region)						# to Flash ME only Region
		cli.SpiFlash('write', r"C:\SVShare\Amol\XmlCli\KBL\Amol\GBE.bin", cli.fwp.GBE_Region)					# to Flash GBE only Region
		cli.SpiFlash('write', r"C:\SVShare\Amol\XmlCli\KBL\Amol\Descriptor.bin", cli.fwp. Descriptor_Region)	# to Flash Descriptor only Region
		cli.SpiFlash('write', r"C:\SVShare\Amol\XmlCli\KBL\Amol\IFWI.bin", cli.fwp. SpiRegionAll)				# to Flash Full SPI
		cli.SpiFlash('write', r"<file>", RegionOffset= Offset)													# to Flash SPI Region from Offset to Offset+Sizeof(file)

		# For Reading the SPI flash run one of following commands.
		cli.SpiFlash('read', r"<file_To_Save>", cli.fwp.BIOS_Region)						# provide desired region and save it to the given file
		cli.SpiFlash('read', r"<file_To_Save>", RegionOffset= Offset, RegionSize= Size)		# to fetch SPI Region from Offset to Offset+Size and save it to the given file
		# SPI ‘read’ operation doesn’t need a reboot of the system, but if you are using ‘write’ operation, its desired to reboot you system after its done. Please verify that your new IFWI or BIOS ROM is flashed by going into the setup page and reading the BIOS version.


	# Add MSR & IO Read/Write CLI functions. Only for DCG
		#Usage:
			IoAccess(operation, IoPort, Size, IoValue):
			MsrAccess(operation, MsrNumber, ApicId, MsrValue)

		#Example:
			cli.IoAccess(cli.clb.IO_WRITE_OPCODE, 0x84, 1, 0xFA)
			cli.IoAccess(cli.clb.IO_READ_OPCODE, 0x84, 1)
			cli.MsrAccess(cli.clb.READ_MSR_OPCODE, 0x53, 0)
			cli.MsrAccess(cli.clb.WRITE_MSR_OPCODE, 0x1A0, 0, 0x1)


	# Usage Instructions to run Python.efi from EFI shell:
		Download and unzip the Python EFI Package from \\bascrd101\svshare\amol\XmlCliRefScripts\PythonEFI_v1.2.7z
		Copy EFI folder to USB Stick
		Insert USB Stick to the DUT (Device Under Test)
		Boot to EFI shell
		If USB Stick is detected as FS0: file system Type FS0: on the shell prompt to get FS0:> prompt string on the shell
		From the shell prompt issue the following command "Python.efi -$"     -  to get into interactive mode of interpreter
		if you want to run any script from file say MyScript.py, Copy the script to USB Stick run the following command "Python.efi <pathToScriptDirectoryonUSBStick>\MyScript.py"

		#To enable XmlCli Python reference Scripts support on EFI Shell:
			In the above steps please following as an aditional step.
			Copy XmlCli reference Scripts folder under EFI folder of the USB Stick
			you can now import the XmlCli scripts and make use of it as usual, please note the "import XmlCli as cli" will automatically detect the UEFI as interface Type.
				import sys
				sys.path.append(r"<FS0:\EFI\XmlCli>")
				import XmlCli as cli
				cli.savexml()
				cli.CvReadKnobs("Knob_A=Val_1, Knob_B=Val_2")
				cli.CvProgKnobs("Knob_A=Val_1, Knob_B=Val_2")
