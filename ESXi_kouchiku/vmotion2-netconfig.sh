#!/bin/sh

### Set Variables ###################

C_DIR=`pwd`
DATE_A=`date +"%Y%m%d-%H%M"`
export ESXNAME=`hostname -s`
T_DIR="${C_DIR}/${ESXNAME}_config"
TV_DIR="${T_DIR}/vib"
TC_DIR="${T_DIR}/conf"
TN_DIR="${T_DIR}/network"
TF_DIR="/vmfs/volumes/datastore1/${ESXNAME}-temp"
CONF_D="${C_DIR}/config_files"

## VMkernel(vMotion2) ##
if [ -e ${CONF_D}/vmk-vmotion2-inf.txt ];then
        V2KSW=`grep ${ESXNAME} "${CONF_D}/vmk-vmotion2-inf.txt" |awk '{print $2}'`
        V2KNM=`grep ${ESXNAME} "${CONF_D}/vmk-vmotion2-inf.txt" |awk '{print $3}'`
        V2KIP=`grep ${ESXNAME} "${CONF_D}/vmk-vmotion2-inf.txt" |awk '{print $4}'`
        V2KSM=`grep ${ESXNAME} "${CONF_D}/vmk-vmotion2-inf.txt" |awk '{print $5}'`
        V2KDG=`grep ${ESXNAME} "${CONF_D}/vmk-vmotion2-inf.txt" |awk '{print $6}'`
        V2KVL=`grep ${ESXNAME} "${CONF_D}/vmk-vmotion2-inf.txt" |awk '{print $7}'`
        V2KIF=`grep ${ESXNAME} "${CONF_D}/vmk-vmotion2-inf.txt" |awk '{print $8}'`
else
        echo "### VMkernel Config File Not Exist###"
        exit 0
fi

#####################################

### Add vMorion VMkernel Interface 2 ###
ping -c 2 "${V2KIP}" > /dev/null 2>&1
if [ $? -ne 0 ];then
#	esxcli network vswitch standard add --vswitch-name "${V2KSW}"
        esxcli network vswitch standard portgroup add --portgroup-name "${V2KNM}" --vswitch-name "${V2KSW}"
        echo "" > /dev/null
#        esxcli network vswitch standard portgroup set --vlan-id "${V2KVL}" --portgroup-name "${V2KNM}"
#        echo "" > /dev/null
        esxcli network ip interface add --interface-name "${V2KIF}" --portgroup-name "${V2KNM}"
        echo "" > /dev/null
        esxcli network ip interface ipv4 set --interface-name "${V2KIF}" --ipv4 "${V2KIP}" --netmask "${V2KSM}" --type static
        echo "### OK Add Provision VMkernel Interface ###"
        vim-cmd hostsvc/net/refresh
        echo "### ESXi Network Refresh  ###"
else
        echo "### Exist ${V2KIP} Not Add Provision VMkernel Interface ###"
        exit 0
fi

### Enable VMkernel Interface2 for vMotion ###
vim-cmd hostsvc/vmotion/vnic_set "${V2KIF}"
if [ $? -eq 0 ];then
        echo "### OK Enable vMotion ###"
        vim-cmd hostsvc/net/refresh
        echo "### ESXi Network Refresh  ###"
else
        echo "### NG Enable vMotion ###"
        vim-cmd hostsvc/net/refresh
        echo "### ESXi Network Refresh  ###"
fi

sync;sync
# /bin/reboot
echo "### $0 Shell END ###"
exit 0
