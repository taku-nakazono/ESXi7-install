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

## VMkernel(vMotion) ##
if [ -e ${CONF_D}/vmk-vmotion-inf.txt ];then
        VMKSW=`grep ${ESXNAME} "${CONF_D}/vmk-vmotion-inf.txt" |awk '{print $2}'`
        VMKNM=`grep ${ESXNAME} "${CONF_D}/vmk-vmotion-inf.txt" |awk '{print $3}'`
        VMKIP=`grep ${ESXNAME} "${CONF_D}/vmk-vmotion-inf.txt" |awk '{print $4}'`
        VMKSM=`grep ${ESXNAME} "${CONF_D}/vmk-vmotion-inf.txt" |awk '{print $5}'`
        VMKDG=`grep ${ESXNAME} "${CONF_D}/vmk-vmotion-inf.txt" |awk '{print $6}'`
        VMKVL=`grep ${ESXNAME} "${CONF_D}/vmk-vmotion-inf.txt" |awk '{print $7}'`
        VMKIF=`grep ${ESXNAME} "${CONF_D}/vmk-vmotion-inf.txt" |awk '{print $8}'`
else
        echo "### VMkernel Config File Not Exist###"
        exit 0
fi

#####################################

### Add vMotion VMkernel Interface ###
ping -c 2 "${VMKIP}" > /dev/null 2>&1
if [ $? -ne 0 ];then
        esxcli network vswitch standard portgroup add --portgroup-name "${VMKNM}" --vswitch-name "${VMKSW}"
        echo "" > /dev/null
#        esxcli network vswitch standard portgroup set --vlan-id "${VMKVL}" --portgroup-name "${VMKNM}"
#        echo "" > /dev/null
        esxcli network ip interface add --interface-name "${VMKIF}" --portgroup-name "${VMKNM}"
        echo "" > /dev/null
        esxcli network ip interface ipv4 set --interface-name "${VMKIF}" --ipv4 "${VMKIP}" --netmask "${VMKSM}" --type static
        echo "### OK Add vMotion VMkernel Interface ###"
        vim-cmd hostsvc/net/refresh
        echo "### ESXi Network Refresh  ###"
else
        echo "### Exist ${VMKIP} Not Add vMotion VMkernel Interface ###"
        exit 0
fi

### Enable VMkernel Interface for vMotion ###
vim-cmd hostsvc/vmotion/vnic_set "${VMKIF}"
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
