#!/bin/sh

### Set Variables ###################

C_DIR=`pwd`
DATE_A=`date +"%Y%m%d-%H%M"`
export ESXNAME=`hostname -s`

### Set Directories & Files #########

T_DIR="${C_DIR}/${ESXNAME}_config"
TV_DIR="${T_DIR}/vib"
TC_DIR="${T_DIR}/conf"

#####################################

### Function ########################
runapp()
{
	## RAID LSI ##
	RLNUM=`ls ${PP_DIR}/lsi |wc -l`
	if [ ${RLNUM} -ne 0 ];then
		if [ $1 -eq 60 ];then
        		RDLSI=`ls ${PP_DIR}/lsi |grep offline_bundle`
        		esxcli software vib install -d "${PP_DIR}/lsi/${RDLSI}" >> "${TV_DIR}/NEC_PPS.txt"
		elif [ $1 -eq 70 ];then
			RDLSI=`ls ${PP_DIR}/lsi |grep zip`
			esxcli software component apply -d "${PP_DIR}/lsi/${RDLSI}" >> "${TV_DIR}/NEC_PPS.txt"
		else
			"### RAID LSI version failed ###"
		fi
        	echo "### RAID LSI Installed ###"
	else
	echo "### RAID LSI Not Installed ###"
	fi

	## NEC StoragePathSavior ##
	SVNUM=`ls ${PP_DIR}/sps |wc -l`
	if [ ${SVNUM} -ne 0 ];then
		if [ $1 -eq 60 ];then
        		VMSPS=`ls ${PP_DIR}/sps |grep offline_bundle`
        		esxcli software vib install -d "${PP_DIR}/sps/${VMSPS}" >> "${TV_DIR}/NEC_PPS.txt"
		elif [ $1 -eq 70 ];then
			VMSPS=`ls ${PP_DIR}/sps |grep zip`
			esxcli software component apply -d "${PP_DIR}/sps/${VMSPS}" >> "${TV_DIR}/NEC_PPS.txt"
		else
                        "### SPS version failed ###"
		fi
        	echo "### NEC StoragePathSavior Installed ###"
	else
        	echo "### NEC StoragePathSavior Not Installed ###"
	fi

	## NEC AMS and iLO ##
	ILNUM=`ls ${PP_DIR}/ilo |wc -l`
	if [ ${ILNUM} -ne 0 ];then
		if [ $1 -eq 60 ];then
        		AMSIL=`ls ${PP_DIR}/ilo |grep bundle`
        		esxcli software vib install -n amsd -d "${PP_DIR}/ilo/${AMSIL}" >> "${TV_DIR}/NEC_PPS.txt"
        		esxcli software vib install -n ilo -d "${PP_DIR}/ilo/${AMSIL}" >> "${TV_DIR}/NEC_PPS.txt"
       		elif [ $1 -eq 70 ];then
			AMSIL=`ls ${PP_DIR}/ilo |grep amsd`
			ILODR=`ls ${PP_DIR}/ilo |grep ilo-`
			esxcli software component apply -d "${PP_DIR}/ilo/${AMSIL}" >> "${TV_DIR}/NEC_PPS.txt"
			esxcli software component apply -d "${PP_DIR}/ilo/${ILODR}" >> "${TV_DIR}/NEC_PPS.txt"
		else
			"### AMSD & iLO version failed ###"
		fi
		echo "### NEC AMSD & iLO Installed ###"
	else
        	echo "### NEC AMSD & iLO Not Installed ###"
	fi

	## NEC WBEM and SSA CLI ##
	WBNUM=`ls ${PP_DIR}/wbm |wc -l`
	if [ ${WBNUM} -ne 0 ];then
		if [ $1 -eq 60 ];then
#        WBMPR=`ls ${PP_DIR}/wbm |grep smx-provider |grep vib`
#        esxcli software vib install -v "${PP_DIR}/wbm/${WBMPR}" >> "${TV_DIR}/NEC_PPS.txt"
			SSACL=`ls ${PP_DIR}/wbm |grep ssacli |grep vib`
        		esxcli software vib install -v "${PP_DIR}/wbm/${SSACL}" >> "${TV_DIR}/NEC_PPS.txt"
		elif [ $1 -eq 70 ];then
			SSACL=`ls ${PP_DIR}/wbm |grep ssacli |grep zip`
			esxcli software component apply -d "${PP_DIR}/wbm/${SSACL}" >> "${TV_DIR}/NEC_PPS.txt"
		else
               		"### SSACLI version failed ###"
        	fi
        	echo "### NEC SSA CLI Installed ###"
	else
       		echo "### NEC SSA CLI Not Installed ###"
	fi
}

#####################################

### running #########################

case ${ESXIVER} in
        "6.0.0" )
		PP_DIR="${C_DIR}/esxi_pp_60"
		echo -e "DATE: ${DATE_A} ESXi Ver: ${ESXIVER}\n\n" > "${TV_DIR}/NEC_PPS.txt"
		runapp 60
		;;
	"6.5.0" )
		PP_DIR="${C_DIR}/esxi_pp_65"
		echo -e "DATE: ${DATE_A} ESXi Ver: ${ESXIVER}\n\n" > "${TV_DIR}/NEC_PPS.txt"
		runapp 60
		;;
	"6.7.0" )
		PP_DIR="${C_DIR}/esxi_pp_67"
		echo -e "DATE: ${DATE_A} ESXi Ver: ${ESXIVER}\n\n" > "${TV_DIR}/NEC_PPS.txt"
		runapp 60
		;;
	"7.0.3" )
		PP_DIR="${C_DIR}/esxi_pp_73"
		echo -e "DATE: ${DATE_A} ESXi Ver: ${ESXIVER}\n\n" > "${TV_DIR}/NEC_PPS.txt"
		runapp 70
		;;
	* )
		echo "### NOT FOUND PP Directory ###"
		;;
esac

#####################################

exit 0
