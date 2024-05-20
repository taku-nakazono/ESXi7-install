#!/bin/sh

### Set Variables ###################

C_DIR=`pwd`
DATE_A=`date +"%Y%m%d-%H%M"`
export ESXNAME=`hostname -s`
export ESXIVER=`esxcli system version get |grep Version |awk '{print $2}'`

### Set Directories & Files #########

T_DIR="${C_DIR}/${ESXNAME}_config"
TV_DIR="${T_DIR}/vib"
TC_DIR="${T_DIR}/conf"
CONF_D="${C_DIR}/config_files"

PT_DIR="${C_DIR}/esxi_patch_"
PTCHLST="${CONF_D}/list-esxipatch.txt"

TF_DIR="/vmfs/volumes/datastore1/${ESXNAME}-temp"
# DATAST=`ls -l /vmfs/volumes |grep -i storage |awk '{print $11}'`
DATAST=`ls -l /vmfs/volumes/datastore1 |awk '{print $11}'`
SCRT_DIR="/vmfs/volumes/${DATAST}/${ESXNAME}-scratch"

#####################################

cd ${C_DIR}

### ESXi Mode Check ###
vim-cmd hostsvc/hostsummary |grep -i MaintenanceMode |awk '{print $3}' |grep false > /dev/null
if [ $? -eq 0 ];then
        echo "### ESXi Maintenance Mode On ###"
        vim-cmd hostsvc/maintenance_mode_enter > /dev/null 2>&1
else
        echo "### ESXi Already Maintenance Mode ###"
fi

### Pre Script Check ###
if [ ! -e ${PTCHLST} ];then
        echo "### NOT EXIT PATCH FILE ${PTCHLST} !! ###"
        exit 1
fi

if [ ! -f ${PTCHLST} ];then
        echo "### NOT FILE ${PTCHLST} !! ###"
        exit 1
fi

#grep "${ESXNAME}-scratch" /etc/vmware/locker.conf > /dev/null
#if [ $? -eq 0 ];then
#	mkdir -p ${TV_DIR}
# 	mkdir -p ${TC_DIR}
#	cp -p /etc/vmware/locker.conf ${TC_DIR}/locker.conf
#	cp -p /etc/hosts ${TC_DIR}/hosts
#	cp -p /etc/ssh/sshd_config ${TC_DIR}/sshd_config
#else
#	echo "### 1-esxi_config.sh execute? ###"
#	exit 0
#fi
#esxcli system version get |grep "6.0.0" > /dev/null
#if [ $? -eq 0 ];then
#	echo "### ESXi Version 6.0 Check OK ###"
#else
#	echo "### ESXi Version is not 6.0 ###"
#	exit 0
#fi

### Takeout Info ###
mkdir -p ${TV_DIR}
esxcli software vib list > ${TV_DIR}/pre-esxcli_software_vib_list.txt
esxcli system version get > ${TV_DIR}/pre-esxcli_system_version_get.txt
esxcli software profile get > ${TV_DIR}/pre-esxcli_software_profile_get.txt

### MD5SUM Check ESXi Patch ###
md5match()
{
        grep ^${LSTCHCK} ${PTCHLST} > /dev/null
        if [ $? -eq 0 ];then
                echo "### ${LSTCHCK} MATCH PATCHLIST ###"
        else [ $? -ne 0 ]
                echo "### !!! NOT MATCH PATCHLIST !!! PATCHNAME ${LSTCHCK} ###"
                exit 1
        fi

        LISTMD5=`grep ^${LSTCHCK} ${PTCHLST} |awk '{print $2}'`
        REALMD5=`md5sum ${PT_DIR}*/${LSTCHCK} |awk '{print $1}'`
        if [ ${LISTMD5} = ${REALMD5} ];then
                echo "### ${LSTCHCK} MATCH MD5SUM ${REALMD5}  ###"
                echo "${LSTCHCK} MATCH MD5SUM" >> ${C_DIR}/patch_md5_check.txt
        else
                echo "### !!! NOT MATCH PATCHLIST !!! MD5SUM LIST ${LSTCHCK} ${LISTMD5} ###"
                exit 1
        fi
}

grep ^VMware-ESXi ${PTCHLST}
if [ $? -eq 1 ];then
	echo "### ESXi's Patch Not Exist ###"
	exit 1
else
	if [ -e ${C_DIR}/patch_md5_check.txt ];then
		echo "### CHECKED MD5SUM PATCHES ###"
	else
		SLCTOS=`uname`
		if [ ${SLCTOS} = "VMkernel" ];then
			set `ls ${PT_DIR}* |grep ^VMware-ESXi`
			for LSTCHCK in $@
			do
				md5match 1
			done
		else
			echo "### NOT VMkernel ###"
			exit 1
		fi
	fi
fi


### Runnning ESXi Patch ###
runpatch()
{
	### RUN ESXi Patches ###
	if [ $1 = 6* ];then
		PTCHVER=ESXi$1
		for PTCHNAME in `grep ^"${PTCHVER}" ${PTCHLST} |cut -f 1`
		do
			PROFNAME=`grep ${PTCHNAME} ${PTCHLST} |cut -f 3`
			PTCHMEMO="${TV_DIR}/${PTCHNAME}-${PROFNAME}.txt"
			echo -e "DATE: ${DATE_A} HOSTNAME: ${ESXNAME}\n\n" > ${PTCHMEMO}
			esxcli software profile update --depot=${PT_DIR}$1/${PTCHNAME} --profile ${PROFNAME} >> ${PTCHMEMO}
			if [ $? -eq 0 ];then
				echo "### PatchName: ${PTCHNAME}  ProfileName: ${PROFNAME} update OK ###"
			else
				echo "### Can't Update PatchName: ${PTCHNAME}  ProfileName: ${PROFNAME}"
			fi
		done
	elif [ $1 = 73 ];then
		PTCHVER=ESXi
		for PTCHNAME in `grep ${PTCHVER} ${PTCHLST} |cut -f 1`
		do
			PROFNAME=`grep ${PTCHNAME} ${PTCHLST} |cut -f 3`
			PTCHMEMO="${TV_DIR}/${PTCHNAME}-${PROFNAME}.txt"
			echo -e "DATE: ${DATE_A} HOSTNAME: ${ESXNAME}\n\n" > ${PTCHMEMO}
			esxcli software profile update --depot=${PT_DIR}$1/${PTCHNAME} --profile ${PROFNAME} >> ${PTCHMEMO}
			if [ $? -eq 0 ];then
                                echo "### PatchName: ${PTCHNAME}  ProfileName: ${PROFNAME} update OK ###"
                        else
                                echo "### Can't Update PatchName: ${PTCHNAME}  ProfileName: ${PROFNAME}"
                        fi
		done
	else 
		echo "### not run patch  ###"
	fi
}

case ${ESXIVER} in
	"6.0.0" ) 
		### ESXi DRs ###
		sh ${C_DIR}/esxidrvs-install.sh
		### ESXi Patchs ###
		runpatch 60
		### ESXi PPs ###
		sh ${C_DIR}/esxipps-install.sh
		;;
	"6.5.0" )
		### ESXi DRs ###
		sh ${C_DIR}/esxidrvs-install.sh
		### ESXi Patchs ###
		runpatch 65
		### ESXi PPs ###
		sh ${C_DIR}/esxipps-install.sh
		;;
	"6.7.0" )
                ### ESXi DRs ###
                sh ${C_DIR}/esxidrvs-install.sh
                ### ESXi Patchs ###
                runpatch 67
                ### ESXi PPs ###
                sh ${C_DIR}/esxipps-install.sh
                ;;
	"7.0.3" )
                ### ESXi DRs ###
                sh ${C_DIR}/esxidrvs-install.sh
                ### ESXi Patchs ###
                runpatch 73
                ### ESXi PPs ###
                sh ${C_DIR}/esxipps-install.sh
                ;;
	* )
		echo "### NOT RUN PATCH ###"
		;;
esac	

### Scratch Config ###
echo "### Set Scratch Partition ###"
mkdir -p ${TF_DIR}
mkdir -p ${SCRT_DIR}
PL_DIR=`cat /etc/vmware/locker.conf |awk '{print $1}'`
cp -p /etc/vmware/locker.conf ${TF_DIR}/locker.conf_${DATE_A}
echo ${SCRT_DIR} 1 > /etc/vmware/locker.conf

### END ###
sync;sync
# /bin/reboot
echo "### Plese Reboot type in [ /bin/reboot ]"
echo "### $0 Shell END ###"
