#!/usr/bin/env python2.7

import os, sys, getopt
XML_PATH = os.path.dirname(os.path.realpath(__file__))
#XML_PATH = '/root/bios_xml/'
XML_FILE = XML_PATH + '/target.xml'
INI_PATH = XML_PATH + '/out/TmpBiosKnobs.ini'
DELTA_INI = '/root/delta.ini'
FULL_INI = '/root/bios_full.ini'

def set_default_bios():
    sys.path.append(r"%s"%(XML_PATH))
    import XmlCli as cli
    cli.clb._setCliAccess("linux")
    try:
        cli.clb.ConfXmlCli()
    except:
        print 'error'
        sys.exit(2)
    cli.CvLoadDefaults()

def get_xml():
    sys.path.append(r"%s"%(XML_PATH))
    import XmlCli as cli
    cli.clb._setCliAccess("linux")
    try:
        cli.clb.ConfXmlCli()
    except:
        print 'error'
        sys.exit(2)
    cli.savexml(r"%s"%(XML_FILE))
    print XML_FILE

def set_bios(bios_items):
    sys.path.append(r"%s"%(XML_PATH))
    import XmlCli as cli
    cli.clb._setCliAccess("linux")
    try:
        cli.clb.ConfXmlCli()
    except:
        print 'error'
        sys.exit(2)
    cli.CvProgKnobs("%s"%(bios_items))
    print 'Set ' + bios_items + ' done.'

def set_ini_bios(ini_path):
    sys.path.append(r"%s"%(XML_PATH))
    import XmlCli as cli
    cli.clb._setCliAccess("linux")
    try:
        cli.clb.ConfXmlCli()
    except:
        print 'error'
        sys.exit(2)
    cli.clb.KnobsIniFile=r"%s"%(ini_path)
    cli.CvProgKnobs()

def get_delta_ini(full_ini_name):
    get_delta_ini(full_ini_name)
    if os.path.exists(full_ini):
        print 'full_ini: ' + full_ini
    else:
        print 'full_ini: ' + full_ini + ' not exist'
        sys.exit()
    get_xml()
    os.system('../generate_ini.sh -f %s -o %s'%(XML_FILE,current_ini))
    os.system('../generate_ini.sh -c %s -t %s -o %s'%(current_ini,full_ini,DELTA_INI))

def main(argv):
    get_type = ''
    bios_set_items = ''
    ini_file = ''
    current_ini = 'current.ini'
    try:
        opts, args = getopt.getopt(argv, "hg:s:d:i:c:e:f:", ["get_type=","bios_set_items=","bios_set_items="])

    except getopt.GetoptError:
        print 'Error: requestTest.py -g "default|current" | -s "SecurityMode=0x00, TBTHotSMI=0x00" | -d "SecurityMode=0x00, TBTHotSMI=0x00"'
        sys.exit(2)

    for opt, arg in opts:
        if opt == "-h":
            print sys.argv[0] + ' -g "default|current"| -s "SecurityMode=0x00, TBTHotSMI=0x00"| -d "SecurityMode=0x00, TBTHotSMI=0x00"| -i bios.ini| -c full.ini| -e full.ini| -f XML_FILE to get full ini'
            print 'For example:'
            print 'python2.7 bios_set.py -d "DiscreteTbtSupport=0x1,TbtBootOn=0x2,TBTHotSMI=0x0,Gpio5Filter=0x0,TBTHotNotify=0x0,DTbtController_0=0x1,TBTSetClkReq=0x1,TbtLtr=0x1,DTbthostRouterPortNumber_0=0x2,DTbtPcieExtraBusRsvd_0=0x6A,DTbtPcieMemRsvd_0=0x6A,DTbtPcieMemRsvd_0=0x2E1,DTbtPciePMemRsvd_0=0x4A0,Win10Support=0x2,TrOsup=0x1,TbtL1SubStates=0x0,Rtd3Tbt=0x1,TbtVtdBaseSecurity=0x1,EnableSgx=0x1,PrmrrSize=0x8000000,EnableAbove4GBMmio=0x1,PrimaryDisplay_inst_3=0x0,PcieRootPortAspm_20=0x2,PcieRootPortHPE_20=0x1,PcieRootPortDptp_20=0x5,PcieSwEqOverride=0x1"'
            print 'bios_xml folder path: ' + XML_PATH
            sys.exit()

        elif opt in ("-g", "--gId"):
            get_type = arg
            print 'Get xmli type:' + get_type
            if get_type == "default":
                set_default_bios()
            elif get_type == "current":
                print 'Will get current BIOS xml'
            else:
                print 'Unknow type:' + get_type + ', will get current xml'
            get_xml()
        elif opt in ("-s", "--sId"):
            bios_set_items = arg
            print 'Set bios items:' + bios_set_items
            set_bios(bios_set_items)
            get_xml()
            print INI_PATH
        elif opt in ("-d", "--dId"):
            bios_set_items = arg
            print 'Set bios items based on default BIOS setting:' + bios_set_items
            set_default_bios()
            set_bios(bios_set_items)
            get_xml()
            print INI_PATH
        elif opt in ("-i", "--iId"):
            ini_file = arg
            if os.path.exists(ini_file):
                print 'ini_file: ' + ini_file
            else:
                print 'ini_file: ' + ini_file + ' not exist'
                sys.exit()
            set_ini_bios(ini_file)
            get_xml()
        elif opt in ("-c", "--cId"):
            full_ini_name = arg
            get_delta_ini(full_ini_name)
        elif opt in ("-e", "--eId"):
            full_ini_name = arg
            get_delta_ini(full_ini_name)
            set_ini_bios(DELTA_INI)
            get_xml()
        elif opt in ("-f", "--fId"):
            xml_file = arg
            os.system('../generate_ini.sh -f %s -o %s'%(xml_file,FULL_INI))
        else:
            print 'parm not correct, please -h to check'
            sys.exit()

if __name__ == "__main__":
    main(sys.argv[1:])
