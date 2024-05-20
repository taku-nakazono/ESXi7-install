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
rundrv()
{
	## FC Driver ##
	FCNUM=`ls ${DR_DIR}/fcd |wc -l`
	if [ ${FCNUM} -ne 0 ];then
		if [ $1 -eq 60 ];then
			FCDRV=`ls ${DR_DIR}/fcd |grep offline_bundle`
			esxcli software vib install -d "${DR_DIR}/fcd/${FCDRV}" >> "${TV_DIR}/NEC_DRV.txt"
		elif [ $1 -eq 70 ];then
			FCDRV=`ls ${DR_DIR}/fcd |grep zip |grep -v package`
			esxcli software component apply -d "${DR_DIR}/fcd/${FCDRV}" >> "${TV_DIR}/NEC_DRV.txt"
		else
			"### FC Driver version failed ###"
		fi
		echo "### FC Driver Installed ###"
	else
        	echo "### FC Driver Not Installed ###"
	fi

	## NIC Driver ##
	NCNUM=`ls ${DR_DIR}/nic |wc -l`
	if [ ${NCNUM} -ne 0 ];then
		if [ $1 -eq 60 ];then
        		NCDRV=`ls ${DR_DIR}/nic |grep offline_bundle`
        		esxcli software vib install -d "${DR_DIR}/nic/${NCDRV}" >> "${TV_DIR}/NEC_DRV.txt"
        	elif [ $1 -eq 70 ];then
			NCDRV=`ls ${DR_DIR}/nic |grep zip |grep -v package`

			esxcli software component apply -d "${DR_DIR}/nic/${NCDRV}" >> "${TV_DIR}/NEC_DRV.txt"
		else
                        "### NIC Driver version failed ###"
		fi
		echo "### NIC Driver Installed ###"
	else
        	echo "### NIC Driver Not Installed ###"
	fi

	## NIC Driver 2 ##
	N2NUM=`ls ${DR_DIR}/nic2 |wc -l`
	if [ ${N2NUM} -ne 0 ];then
		if [ $1 -eq 60 ];then
        		N2DRV=`ls ${DR_DIR}/nic2 |grep offline_bundle`
        		esxcli software vib install -d "${DR_DIR}/nic2/${N2DRV}" >> "${TV_DIR}/NEC_DRV.txt"
        	elif [ $1 -eq 70 ];then
			N2DRV=`ls ${DR_DIR}/nic2 |grep zip |grep -v package`
			esxcli software component apply -d "${DR_DIR}/nic2/${N2DRV}" >> "${TV_DIR}/NEC_DRV.txt"
		else
                        "### NIC Driver 2 version failed ###"
                fi
		echo "### NIC Driver 2 Installed ###"
	else
        	echo "### NIC Driver 2 Not Installed ###"
	fi	

	## RAID Driver ##
	RANUM=`ls ${DR_DIR}/raid |wc -l`
	if [ ${RANUM} -ne 0 ];then
		if [ $1 -eq 60 ];then
        		RADRV=`ls ${DR_DIR}/raid |grep offline_bundle`
        		esxcli software vib install -d "${DR_DIR}/raid/${RADRV}" >> "${TV_DIR}/NEC_DRV.txt"
		elif [ $1 -eq 70 ];then
			RADRV=`ls ${DR_DIR}/raid |grep zip |grep -v package`
			esxcli software component apply -d "${DR_DIR}/raid/${RADRV}" >> "${TV_DIR}/NEC_DRV.txt"
		else
                        "### RAID Driver 2 version failed ###"
                fi
        	echo "### RAID Driver Installed ###"
	else
        	echo "### RAID Driver Not Installed ###"
	fi
}

#####################################

### running #########################

case ${ESXIVER} in
        "6.0.0" )
                DR_DIR="${C_DIR}/esxi_drv_60"
                echo -e "DATE: ${DATE_A} ESXi Ver: ${ESXIVER}\n\n" > "${TV_DIR}/NEC_DRV.txt"
		rundrv 60
                ;;
        "6.5.0" )
                DR_DIR="${C_DIR}/esxi_drv_65"
                echo -e "DATE: ${DATE_A} ESXi Ver: ${ESXIVER}\n\n" > "${TV_DIR}/NEC_DRV.txt"
		rundrv 60
                ;;
        "6.7.0" )
                DR_DIR="${C_DIR}/esxi_drv_67"
                echo -e "DATE: ${DATE_A} ESXi Ver: ${ESXIVER}\n\n" > "${TV_DIR}/NEC_DRV.txt"
                rundrv 60
		;;
        "7.0.3" )
                DR_DIR="${C_DIR}/esxi_drv_73"
                echo -e "DATE: ${DATE_A} ESXi Ver: ${ESXIVER}\n\n" > "${TV_DIR}/NEC_DRV.txt"
                rundrv 70
		;;
        * )
                echo "### NOT FOUND DRV Directory ###"
                ;;
esac

#####################################

exit 0

