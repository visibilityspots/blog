Title:       wireless bond archlinux arm
Author:      Jan
Date: 	     2016-10-17 21:00
Slug:	     wireless-bond-archlinux
Tags: 	     wireless, bond, vip, wlan0, wlan1, static, ip, wpa_supplicant, netctl, failover, bonding, bond0, archlinux, raspberry, pi, arm, alarm
Status:	     published
Modified:    2016-10-17

for one of my projects, the [sms-twitter wall](../social-media-wall.html) setup, I configured a raspberry pi with 2 wireless network interfaces to connect through a hotspot enabled on an android device. I discovered on previous events that the wireless adapter failed on me from time to time. So I went to the internet to look if I could add a second interface and bond them together.

I found a lot of documentation on how to bond an active-backup strategy with a wired and a wireless interfaces but didn't found a setup with 2 wireless interfaces. After a while I figured out how it can be accomplished, even with a static ip. This static ip was necessary because the phone is receiving text messages converting them and sending them to the pi's ip address so the smswall could handle them.

Another side note was the wired connection, when at home I wanted to plug the ethernet cable so I could connect to my NAS for backups and to by pass the slow mobile connection for debugging purposes.

A lot of usable documentation I found on the archwiki obviously, like the [netctl article](https://wiki.archlinux.org/index.php/netctl#Bonding)

A range of tools needs to be installed on the system, which I did using [yaourt](https://archlinux.fr/yaourt-en)

```
$ yaourt -S netctl wpa_supplicant ifenslave
```

The bonding kernel module needs to be installed and configured

vim /etc/modules-load.d/bonding.conf
```
bonding

/etc/modprobe.d/bonding.conf
```
options bonding mode=active-backup miimon=100 primary=wlan0 max_bonds=0

the netctl wired connection profile
/etc/netcltl/wired

```
Description='A basic static ethernet connection'
Interface=eth0
Connection=ethernet
IP=static
Address=('192.168.0.106/24')
Routes=('default metric 1 via 192.168.0.1')
DNS=('192.168.0.1')
ExcludeAuto=no
Priority=2
```

the netctl profile failover needs to be configured also with a static ip

/etc/netctl/failover
```
Description="bond interface"
Interface=bond0
Connection=bond
BindsToInterfaces=(wlan0 wlan1)
IP=static
Address=('192.168.43.150/24')
Routes=('default metric 100 via 192.168.43.1')
DNS=('192.168.43.1')
```

notice the Router parameter instead of the Gateway, by assigning different metrics both profiles can be used together. Else the will be fighting with each other to configure the default route. And in my experience obviously the one you need (wired) will loose over and over again..

Enable the profiles

```
$ sudo systemctl start netctl-ifplugd@eth0.service
$ sudo systemctl status netctl-ifplugd@eth0.service
$ sudo systemctl enable netctl-ifplugd@eth0.service
```

```
$ sudo netctl enable failover
```

If you like me already had the wireless interface configured in the netctl-auto modus be sure to disable and stop that service!

```
$ sudo systemctl status netctl-ifplugd@eth0.service
$ sudo systemctl stop netctl-ifplugd@eth0.service
$ sudo systemctl disable netctl-ifplugd@eth0.service
```
We should now configure the wireless authentication for both wireless adapters. First calculate the [wpa_passphrase](https://wiki.archlinux.org/index.php/WPA_supplicant#Connecting_with_wpa_passphrase)

```
$ wpa_passphrase SSID passphrase
```

and copy over the output into the following configuration files

/etc/wpa_supplicant/wpa_supplicant-wlan0.conf

```
ctrl_interface=/run/wpa_supplicant-wlan0
update_config=1

network={
	ssid="SSID"
	#psk="passphrase"
	psk=XX
}
```

/etc/wpa_supplicant/wpa_supplicant-wlan1.conf

```
ctrl_interface=/run/wpa_supplicant-wlan1
update_config=1

network={
	ssid="SSID"
	#psk="passphrase"
	psk=XX
}
```

and their dependency configuration files


/etc/systemd/system/wpa_supplicant@wlan0.service.d/customdependency.conf

```
[Unit]
After=netctl@failover.service
```

/etc/systemd/system/wpa_supplicant@wlan1.service.d/customdependency.conf

```
[Unit]
After=wpa_supplicant@wlan0.service
```

I had to configure them in this order since they didn't came up properly if I didn't only one could achieve to authenticate instead of both. By having the wlan1 unit depend on the wlan0 I had tackled it.


When rebooting the device you should see them both connected using 'iwconfig' and only the bond0 and eth0 interfaces having an ip address using 'ifconfig' or 'ip -4 a'

to see the bond status

```
# cat /proc/net/bonding/bond0

Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: wlan0 (primary_reselect always)
Currently Active Slave: wlan0
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: wlan0
MII Status: up
Speed: Unknown
Duplex: Unknown
Link Failure Count: 0
Permanent HW addr: ##:## 
Slave queue ID: 0

Slave Interface: wlan1
MII Status: up
Speed: Unknown
Duplex: Unknown
Link Failure Count: 1
Permanent HW addr: ##:##
Slave queue ID: 0
```

I did some testing by unplugging interfaces, bringing them down through the cli and my system kept online. Even without the ethernet cable plugged ;)

So after some debugging I once again won a fight over the network!! 
