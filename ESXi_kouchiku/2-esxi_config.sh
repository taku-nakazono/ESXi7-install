#!/bin/sh

### Set Variables ###################

C_DIR=`pwd`
DATE_A=`date +"%Y%m%d-%H%M"`
export ESXNAME=`hostname -s`

TF_DIR="/vmfs/volumes/datastore1/${ESXNAME}-temp"
T_DIR="${C_DIR}/${ESXNAME}_config"
TV_DIR="${T_DIR}/vib"
TC_DIR="${T_DIR}/conf"
TN_DIR="${T_DIR}/network"
CONF_D="${C_DIR}/config_files"
DNSNTPF=${CONF_D}/dns-ntp.conf

## Rename Datastore
RLDN="${ESXNAME}_Storage1"

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
if [ -e ${TV_DIR} ];then
        mkdir -p ${TN_DIR}
	mkdir -p ${TC_DIR}
else
        echo "### ESXi Patch Script execute? ###"
        exit 0
fi

### Takeout Info ###
esxcli software vib list > ${TV_DIR}/post-esxcli_software_vib_list.txt
esxcli system version get > ${TV_DIR}/post-esxcli_system_version_get.txt

esxcli network vswitch standard list > ${TN_DIR}/pre-esxcli_network_vswitch_standard_list.txt
esxcli network vswitch standard portgroup list > ${TN_DIR}/pre-esxcli_network_vswitch_standard_portgroup_list.txt
esxcli network ip interface list > ${TN_DIR}/pre-esxcli_network_ip_interface_list.txt
esxcli network ip interface ipv4 get > ${TN_DIR}/pre-esxcli_network_ip_interface_ipv4_get.txt
esxcli network nic list > ${TN_DIR}/pre-esxcli_network_nic_list.txt

cp -p /etc/vmware/locker.conf ${TC_DIR}/locker.conf

### ESXi File Base Config ###
#mkdir -p ${TF_DIR}
echo "### Set hosts File ###"
ls ${CONF_D} |grep hosts > /dev/null 2>&1
if [ $? -eq 0 ];then
	cp -p /etc/hosts ${TF_DIR}/hosts_${DATE_A}
	cp ${CONF_D}/hosts /etc/hosts
	cp -p /etc/hosts ${TC_DIR}/hosts
else 
	echo "### Hosts Config Not Exist ###"
fi
 
echo "### Set SSH ###"
/etc/init.d/SSH status | grep started > /dev/null
if [ $? -eq 0 ];then
        esxcli system settings advanced set -o /UserVars/SuppressShellWarning -i 1
        echo "### SSH Service Alert Config ###"
else
        echo "### SSH Not Started ###"
fi

if [ -e /etc/ssh/sshd_config ];then
	cp -p /etc/ssh/sshd_config ${TF_DIR}/sshd_config_org_${DATE_A}
        sed -ie 's/PasswordAuthentication no/#PasswordAuthentication no/' /etc/ssh/sshd_config
	echo "### sshd config ###"
	cp -p /etc/ssh/sshd_config ${TC_DIR}/sshd_config
else
	echo "### SSH Config Not Exist ###"
fi

### ESXi DNS & NTP Config ###
echo "### Set DNS ###"
ls ${DNSNTPF} > /dev/null 2>&1
if [ $? -eq 0 ];then
	DNSSV01=`grep nameserver1 ${DNSNTPF} |awk '{print $2}'`
	DNSSV02=`grep nameserver2 ${DNSNTPF} |awk '{print $2}'`
	DNSSRCH=`grep search1 ${DNSNTPF} |awk '{print $2}'`
	esxcli network ip dns server add -s ${DNSSV01}
	esxcli network ip dns server add -s ${DNSSV02}
	esxcli network ip dns search add -d ${DNSSRCH}
	esxcli system hostname set --domain ${DNSSRCH}
	cp -p /etc/resolv.conf ${TC_DIR}/resolv.conf
else
        echo "### DNS Config Not Exist ###"
fi

echo "### Set NTP ###"
ls ${DNSNTPF} > /dev/null 2>&1
if [ $? -eq 0 ];then
	NTPSV01=`grep ntpserver1 ${DNSNTPF} |awk '{print $2}'`
	NTPSV02=`grep ntpserver2 ${DNSNTPF} |awk '{print $2}'`
	esxcli system ntp set --server=${NTPSV01} --server=${NTPSV02}
	esxcli system ntp set --enabled=yes
        esxcli network firewall ruleset set --ruleset-id=ntpClient --enabled=true
        /etc/init.d/ntpd restart
	chkconfig ntpd on
	cp -p /etc/ntp.conf ${TC_DIR}/ntp.conf
else
        echo "### NTP Config Not Exist ###"
fi

## vMotion-1
sh ${C_DIR}/vmotion-netconfig.sh

## vMotion-2
if [ $? -eq 0 ];then
        sh ${C_DIR}/vmotion2-netconfig.sh
fi
### SLP Config ###
echo "### SLP Config ###"
esxcli network firewall ruleset set -r CIMSLP -e 1
chkconfig slpd on

### ESXi WBEM TRUE ###
echo "### WBEM TRUE ###"
esxcli system wbem set --enable true

### ESXi Syslog Config ###
echo "### Syslog Config ###"
esxcli system syslog reload
echo "### Set Hostd Rotate ###"
esxcli system syslog config logger list | grep -C 2 "ID: hostd"$ |grep -i "Rotations: 50"$ > /dev/null
if [ $? -eq 1 ];then
        esxcli system syslog config logger set --id=hostd --rotate=50
else
        echo "### Syslog Hostd Rotate 50 ###"
fi

echo "### Set vpxa Rotate ###"
esxcli system syslog config logger list |grep -C 2 "ID: vpxa"$ |grep -i "Rotations: 100"$ > /dev/null
if [ $? -eq 1 ];then
        esxcli system syslog config logger set --id=vpxa --rotate=100
else
        echo "### Syslog vpxa Rotate 100 ###"
fi

echo "### Set vpxa Size ###"
esxcli system syslog config logger list |grep -C 2 "ID: vpxa"$ |grep -i "Size: 20480"$ > /dev/null
if [ $? -eq 1 ];then
        esxcli system syslog config logger set --id=vpxa --size=20480
else
        echo "### Syslog vpxa Size 20480 ###"
fi

echo "### Set vmkernel Rotate ###"
esxcli system syslog config logger list |grep -C 2 "ID: vmkernel"$ |grep -i "Rotations: 100"$ > /dev/null
if [ $? -eq 1 ];then
        esxcli system syslog config logger set --id=vmkernel --rotate=100
else
        echo "### Syslog vmkernel Rotate 100 ###"
fi

echo "### Set vmkernel Size ###"
esxcli system syslog config logger list |grep -C 2 "ID: vmkernel"$ |grep -i "Size: 20480"$ > /dev/null
if [ $? -eq 1 ];then
        esxcli system syslog config logger set --id=vmkernel --size=20480
else
        echo "### Syslog vmkernel Size 20480 ###"
fi

esxcli system syslog reload

### Rename Local Datastore ###
vim-cmd hostsvc/datastore/listsummary |grep datastore1 > /dev/null 2>&1
if [ $? -eq 0 ];then
        PLDN=`ls /vmfs/volumes/ |grep ^datastore1`
        vim-cmd hostsvc/datastore/rename "${PLDN}" "${RLDN}"
        echo "### Rename Local Datastore ###"
        vim-cmd hostsvc/storage/refresh
        echo "### Refresh Storage ###"
else
        echo "### Already Renamed Local Datastore ? ###"
fi

### ESXi Mode Change ###
vim-cmd hostsvc/hostsummary |grep -i MaintenanceMode |awk '{print $3}' |grep true > /dev/null
if [ $? -eq 0 ];then
        echo "### ESXi Maintenance Mode Exit ###"
        vim-cmd hostsvc/maintenance_mode_exit > /dev/null 2>&1
else
        echo "### ESXi Already Normal Mode (Exit Maintenance Mode) ###"
fi

### END ###
sync;sync
# /bin/reboot
echo "### Plese Reboot type in [ /bin/reboot ]"
echo "### $0 Shell END ###"
