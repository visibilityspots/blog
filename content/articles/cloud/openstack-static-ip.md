Title:       Openstack static ip
Author:      Jan
Date: 	     2016-09-05 19:00
Slug:	     openstack-static-ip
Tags: 	     openstack, rdo, kilo, static, ip, dhcp, cloud-init, config, drive, centos
Status:	     published
Modified:    2016-09-05

last couple of days I have been fighting with the way an static ip is configured on an openstack virtual centos 6 instance. In our specific use case we ditched as many network openstack services as possible as I [previously](https://visibilityspots.org/openstack-layer2.html) described.

We want to have the instances running in our current network spaces of the R&D department. In this department until some days ago we didn't had any DHCP server running. But a few weeks back we added an extra remote network space into our platform where we configured a remote compute-node.

This is where the issues started popping up.

In openstack when you spin up an instance with a fixed ip, it will basicly create a neutron port for it, attach it to the vm's NIC interface who will get the ip through DHCP. This makes sense since you want to have your basic images as abstract as possible. But since we disabled a lot of the neutron/openstack network logic our vm got an ip address served by an external dhcp service. Which obviously wasn't what we where looking for.

So we digged in the documentation of cloud-init, openstack and network interfaces. Not much has been documented, or at least we couldn't find it easily about the metadata served by a so called configuration drive.

I figured the metadata is attached through either a /dev/vdb disk or a /dev/sr0 cd-rom drive. In the ec2 metadata the local-ip is indicating the static ip address assigned to the created port. After some looking around the possibilities we decided to write a little script which will fetch this information, rewrite the interface configuration and restart the network service to get the static up and running.

The script is located in /usr/local/bin/reconfigure-static-ip-eth0

```bash
#!/bin/bash


if $(lsblk -l | grep -q sr0); then
        mount /dev/sr0 /mnt
elif $(lsblk -l | grep -q vdb); then
        mount /dev/vdb /mnt
else
        echo "Mountpoint of metadata not found"
        exit 1;
fi


splitip () {
    local IFS
    IFS=.
    set -- $*
    GATEWAY=$GATEWAY"."$@
}


STATIC_IP=$(grep -ri local-ipv4 /mnt/ | tr ',' '\n' | head | grep local-ip | awk -F ' ' '{print $2}' | tr -d '"')
GATEWAY=`echo $STATIC_IP | cut -d"." -f1-3`".1"

echo "VLAN=no" > /etc/sysconfig/network-scripts/ifcfg-eth0
echo "NOZEROCONF=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "NETMASK=255.255.255.0" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "BOOTPROTO=static" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "USERCTL=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "IPADDR=$STATIC_IP" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "GATEWAY=$GATEWAY" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "DEVICE=eth0" >> /etc/sysconfig/network-scripts/ifcfg-eth0

cat /etc/sysconfig/network-scripts/ifcfg-eth0

/etc/init.d/network restart

umount /mnt
```

By calling this script through rc.local (/etc/rc.local) it will reconfigure the network interface right after all services are started. In our use case the instance is only used as a hop through different separated network environments so no services are relying on the network interface.

During our little search we couldn't believe we are the only ones hitting against this issue, I do hope others will read this post and comment with more clean ways to do so but this did solved it for us in a rather clean and fast way to go further with the development of the actual products behind those hop through nodes.
