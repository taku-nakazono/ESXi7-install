#!/bin/sh -x
hostname

export ESXNAME=`hostname -s`

cat /etc/hosts

grep -i password /etc/ssh/sshd_config

esxcli system settings advanced list -o /UserVars/SuppressShellWarning

hostname -f

hostname -s

esxcli network ip dns server list

esxcli network ip dns search list

esxcli system ntp get

esxcli network firewall ruleset list |grep ntp

ntpq -pn

esxcli system syslog config logger list |grep -C 3 "hostd.log"

esxcli system syslog config logger list |grep -C 3 "vpxa.log"

esxcli system syslog config logger list |grep -C 3 "vmkernel.log"

esxcli network firewall ruleset list |grep CIMSLP

/etc/init.d/slpd status

esxcli system wbem get

/etc/init.d/wsman status

/etc/init.d/sfcbd-watchdog status
