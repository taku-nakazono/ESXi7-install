VMware ESX 7.0 Component Installation Instructions
VMware uses a file package called a Component as the mechanism for installing or upgrading software packages on an ESX server.
The file may be installed directly on an ESX server from the command line, orthrough the VMware Update Manager (VUM).  
COMMAND LINE INSTALLATION
New Installation----------------
For new installs, you should perform the following steps:

	1. Copy the component bundle to the ESX server.  Technically, you can
           place the file anywhere that is accessible to the ESX console shell, 
           but for these instructions, we'll assume the location is in '/tmp'.

           Here's an example of using the Linux 'scp' utility to copy the file
           from a local system to an ESX server located at 10.10.10.10:
             scp VMW-esx-7.0.0-VMware-nvmxnet3-2.0.0.30-1vmw.700.1.0.15511075.zip root@10.10.10.10:/tmp

	2. Issue the following command (full path to the file must be specified):
              esxcli software component apply {Component_File}
       
           In the example above, this would be:
              esxcli software component apply -d /tmp/VMW-esx-7.0.0-VMware-nvmxnet3-2.0.0.30-1vmw.700.1.0.15511075.zip

Note: Depending on the certificate used to sign the VIB, you may need to
      change the host acceptance level.  To do this, use the following command:
		esxcli software acceptance set --level=<level>
      Also, depending on the type of VIB being installed, you may have to put
      ESX into maintenance mode.  This can be done through the VI Client, or by
      adding the '--maintenance-mode' option to the above esxcli command.

Upgrade Installation--------------------The upgrade process is similar to a new install as the same command upgradesthe component to a newer, if the prior version is already installed on ESXi server.

	esxcli software component apply -d {Component_File}
VUM INSTALLATION
The VMware Update Manager (VUM) is a plugin for the Virtual Center Server
(vCenter Server).  You can use the VUM UI to install a Component by importing
the associated component package (a ZIP file that contains the VIB and 
metadata).  You can then create an add-on baseline and remediate the
host(s) with this baseline.  Please see the vCenter Server documentation for
more details on VUM.Installing/Uninstalling/Upgrading an I/O Filter Solution Bundles------------------------------------------------------------------Refer to “Installing/Uninstalling/Upgrading an IO Filter” in vSphere APIs for IO Filtering (VAIO)Development Guide available at https://code.vmware.com/group/sdk/7.0.0/io-filter for instructions.
