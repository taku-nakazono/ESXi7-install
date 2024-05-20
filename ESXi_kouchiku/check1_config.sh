#!/bin/sh -x
hostname

esxcli system version get

esxcli software profile get

esxcli software vib list

cat /etc/vmware/locker.conf

#ls /vmfs/volumes/${ESXNAME}_Storage1/${ESXNAME}-scratch/
ls /vmfs/volumes/datastore1/${ESXNAME}-scratch/
