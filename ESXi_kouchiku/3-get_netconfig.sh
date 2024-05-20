#!/bin/sh

### Set Variables ###################

C_DIR=`pwd`
DATE_A=`date +"%Y%m%d-%H%M"`
export ESXNAME=`hostname -s`
T_DIR="${C_DIR}/${ESXNAME}_config"
TV_DIR="${T_DIR}/vib"
TC_DIR="${T_DIR}/conf"
TN_DIR="${T_DIR}/network"
S_DIR="${C_DIR}/dvSwitchSG"

#####################################

### Pre Script Check ###
esxcli network vswitch dvs vmware list |grep "vmk0" > /dev/null 2>&1
DVLIST0=$?
esxcli network vswitch dvs vmware list |grep "vmk1" > /dev/null 2>&1
DVLIST1=$?
DVLISTS=`expr ${DVLIST0} + ${DVLIST1}`

if [ ${DVLISTS} -ne 0 ];then
	echo "### Not Set DvSwitch ###"
	exit 0
fi

### Takeout Info ###
mkdir -p ${TV_DIR}
mkdir -p ${TC_DIR}
mkdir -p ${TN_DIR}

esxcli network vswitch standard list > ${TN_DIR}/post-esxcli_network_vswitch_standard_list.txt
esxcli network vswitch standard portgroup list > ${TN_DIR}/post-esxcli_network_vswitch_standard_portgroup_list.txt
esxcli network ip interface list > ${TN_DIR}/post-esxcli_network_ip_interface_list.txt
esxcli network ip interface ipv4 get > ${TN_DIR}/post-esxcli_network_ip_interface_ipv4_get.txt
esxcli network nic list > ${TN_DIR}/pre-esxcli_network_nic_list.txt
esxcli network vswitch dvs vmware list > ${TN_DIR}/esxcli_network_vswitch_dvs_vmware_list.txt

esxcli software vib list > ${TV_DIR}/post-esxcli_software_vib_list.txt
esxcli system version get > ${TV_DIR}/post-esxcli_system_version_get.txt

mkdir -p "${S_DIR}"
cat ${TN_DIR}/esxcli_network_vswitch_dvs_vmware_list.txt |grep "Port ID:" |awk '{print $3}' > "${S_DIR}/${ESXNAME}-dvPort.txt"
cat ${TN_DIR}/esxcli_network_vswitch_dvs_vmware_list.txt |grep "Client:" |awk '{print $2}' |sed "s/vmnic/${ESXNAME} - vmnic/" |sed "s/vmk/${ESXNAME} - vmk/" > "${S_DIR}/${ESXNAME}-NIC.txt"

### END ###
echo "### $0 Shell END ###"
