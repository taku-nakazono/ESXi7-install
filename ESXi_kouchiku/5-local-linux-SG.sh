#!/bin/sh

### Set Variables ###################

C_DIR=`pwd`
DATE_A=`date +"%Y%m%d-%H%M"`
HOSTN=`hostname -s`
CONF_D="${C_DIR}/config_files"
EFILE="${CONF_D}/vmk-vmotion-inf.txt"
#SETN=`grep '#ESXi' "${EFILE}" |awk '{print $2}' |uniq`
SETN=`cut -c1-5 "${EFILE}" |grep swf |uniq`
#declare -i ESXNUM=`grep ${SETN} ${EFILE} |wc -l`
echo -n "Please type Number of ESXi Servers:"
read ESXNUM
while [ "${ESXNUM}" -eq 0 ]
do
	echo -n "Please Retype Number of ESXi Servers:"
	read ESXNUM
done

S_DIR="${C_DIR}/dvSwitchSG"
#S_DIR="${C_DIR}"

#####################################

### Pre Script Check ###
grep "${HOSTN}" "${EFILE}" > /dev/null 2>&1
if [ $? -eq 0 ];then
        echo "### ESXi Can't Execute This Script ###"
        exit 0
fi

### Gather DvSwitch Hosts Info ###
#for FESXN in `cat "${EFILE}" |grep ${SETN} |awk '{print $1}'`
for FESXN in `cat "${EFILE}" |grep ${SETN} |awk '{print $1}' |tail -${ESXNUM}`
do
	ls ${S_DIR} |grep ${FESXN} > /dev/null 2>&1
	if [ $? -eq 0 ];then
		declare -i WCLP=`wc -l ${S_DIR}/${FESXN}-dvPort.txt |awk '{print $1}'`
		declare -i WCLN=`wc -l ${S_DIR}/${FESXN}-NIC.txt |awk '{print $1}'`
		if [ ${WCLP} -eq ${WCLN} ];then
			paste ${S_DIR}/${FESXN}-* > ${S_DIR}/dvs_${FESXN}.txt
			echo "### ${FESXN} DvSwitch SG File ###"
		else
			echo "### ${FESXN} Can't Configuration DvSwitch ###"
			exit 0
		fi
	else
		echo "### ${FESXN} Not Exist DvSwitch Config File ###"
		exit 0
	fi
done

### Gather ALL DvSwitch Info ###
declare -i LISTNUM=`ls ${S_DIR}/ |grep ^dvs_ |wc -l`
if [ ${ESXNUM} -eq ${LISTNUM} ];then
	cat ${S_DIR}/dvs_* |sort -n |awk '{print $1,$2,$3,$4}' |uniq > ${S_DIR}/DvSwitchSG-ALL.txt
        cat ${S_DIR}/DvSwitchSG-ALL.txt |awk '{print $1}' > ${S_DIR}/DvSwitchSG-line1.csv
        cat ${S_DIR}/DvSwitchSG-ALL.txt |awk '{print $2,$3,$4}' > ${S_DIR}/DvSwitchSG-line2.csv
        echo "## OK dvswitchSG ###"
	unix2dos ${S_DIR}/DvSwitchSG-*
else
        echo "## NG dvswitchSG ###"
        exit 0
fi

### END ###
echo "### $0 Shell END ###"
