#!/bin/sh

### Set Variables ###################

C_DIR=`pwd`
DATE_A=`date +"%Y%m%d-%H%M"`
export ESXNAME=`hostname -s`
T_DIR="${C_DIR}/${ESXNAME}_config"
TS_DIR="${T_DIR}/storage"
P_DIR="${C_DIR}/StoragePath"


#####################################

### Pre Script Check ###
echo "${ESXNAME}" |grep -i ^swf > /dev/null 2>&1
if [ $? -eq 0 ];then
	vim-cmd hostsvc/datastore/listsummary |grep datastore1 > /dev/null 2>&1
	if [ $? -eq 0 ];then
		echo "### 4-esxi_config_mode_change.sh ###"
		exit 0
	fi

### Takeout Info ###
	mkdir -p "${TS_DIR}"
	mkdir -p "${P_DIR}"
	esxcli storage vmfs extent list |sort -k 1 > "${TS_DIR}/esxcli_storage_vmfs_extent_list.txt"
	esxcli storage vmfs extent list |grep Storage |awk '{print$1,$4}' >> "${P_DIR}/esxi_os_volume_path_${ESXNAME}.txt"
	esxcli storage vmfs extent list |grep vkanri |sort -k 1 |awk '{print$1,$4}' >> "${P_DIR}/vkanri_volume_path_${ESXNAME}.txt"

else
	cd "${P_DIR}"
	cat esxi_os_volume_path_*.txt |sort -k 1 > esxi_os_volume_path.txt
	unix2dos esxi_os_volume_path.txt > /dev/null
	cat vkanri_volume_path_*.txt |sort -k 1 |uniq > vkanri_volume_path.txt
	unix2dos vkanri_volume_path.txt > /dev/null
fi

### END ###
echo "### $0 Shell END ###"
