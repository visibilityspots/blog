Apple remote (A1156) - MacBook Pro 3.1 & Ubuntu 10.04
#####################################################
:date: 2011-01-27 22:47
:author: Jan
:tags: apple, linux, ubuntu, infrared, remote, lirc, hardware
:slug: apple-linux-remote
:status: published
:modified: 2011-01-27

It isn't supported by default using Ubuntu but it's as handy as hell, the apple infrared remote control. After some mayor headaches I finally succeeded to configure it manually on my MacBook Pro 3.1 running Ubuntu 10.04.

It's quite easy once you know how.

Installation of the lirc library:
::

	$ sudo apt-get install lirc

Adapting the configuration files (make sure to backup them first!):
::

	$ sudo cp /old/file /new/file.bak


/etc/lirc/hardware.conf
::

	# /etc/lirc/hardware.conf # #Chosen Remote Control REMOTE="Apple Mac mini USB IR Receiver" REMOTE_MODULES="uinput" REMOTE_DRIVER="macmini" REMOTE_DEVICE="/dev/usb/hiddev0" REMOTE_SOCKET="" REMOTE_LIRCD_CONF="" REMOTE_LIRCD_ARGS="--uinput"

	#Chosen IR Transmitter
	 TRANSMITTER="None"
	 TRANSMITTER\_MODULES=""
	 TRANSMITTER\_DRIVER=""
	 TRANSMITTER\_DEVICE=""
	 TRANSMITTER\_SOCKET=""
	 TRANSMITTER\_LIRCD\_CONF=""
	 TRANSMITTER\_LIRCD\_ARGS=""

	#Enable lircd
	 START\_LIRCD=true

	#Don't start lircmd even if there seems to be a good config file
	 #START\_LIRCMD="false"

	#Try to load appropriate kernel modules
	 LOAD\_MODULES="true"

	# Default configuration files for your hardware if any
	 LIRCMD\_CONF=""

	#Forcing noninteractive reconfiguration
	 #If lirc is to be reconfigured by an external application
	 #that doesn't have a debconf frontend available, the noninteractive
	 frontend can be invoked and set to parse REMOTE and TRANSMITTER
	 #It will then populate all other variables without any user input
	 #If you would like to configure lirc via standard methods, be sure
	 #to leave this set to "false"
	 FORCE\_NONINTERACTIVE\_RECONFIGURATION="false"
	 START\_LIRCMD=""

	# Remote settings required by gnome-lirc-properties
	 REMOTE\_MODEL="A1156"
	 REMOTE\_VENDOR="Apple"

	# Receiver settings required by gnome-lirc-properties
	 RECEIVER\_MODEL="Built-in\\ IR\\ Receiver\\ \\(0x8242\\)"
	 RECEIVER\_VENDOR="Apple"

	**/etc/lirc/lircd.conf**

	``# This configuration has been automatically generated # by the GNOME LIRC Properties control panel. # # Feel free to add any custom remotes to the configuration # via additional include directives or below the existing # include directives from your selected remote and/or # transmitter. #``

	# Configuration selected with GNOME LIRC Properties
	 # include

	begin remote
	 name AppleRemote
	 bits 8
	 eps 30
	 aeps 100
	 one 0 0
	 zero 0 0
	 pre\_data\_bits 24
	 pre\_data 0x87EE81
	 gap 211982
	 toggle\_bit\_mask 0x0
	 ignore\_mask 0x0000ff01
	 begin codes
	 KEY\_VOLUMEUP 0x0B
	 KEY\_VOLUMEDOWN 0x0D
	 KEY\_PREVIOUSSONG 0x08
	 KEY\_NEXTSONG 0x07
	 KEY\_PLAYPAUSE 0x04
	 KEY\_MENU 0x02
	 end codes
	 end remote

/etc/modules
::

	# /etc/modules: kernel modules to load at boot time. # # This file contains the names of kernel modules that should be loaded # at boot time, one per line. Lines beginning with "#" are ignored.

	lp
	 usbhid
	 applesmc

/etc/modprobe.d/blacklist
::

	blacklist applesmc blacklist usbhid

Restart the lirc daemon after adopted the configuration:
::

	$ /etc/init.d/lirc restart

To see if the daemon successfully started and is using the right driver:
::

	$ ps aux | grep lirc

If everything went well you should be able to use the remote without any hassle and you could use the apple hardware user experience on a linux distribution!
