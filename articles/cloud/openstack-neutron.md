Title:       Openstack vlan based flat neutron network provider
Author:      Jan
Date: 	     2015-09-29 19:00
Slug:	     vlan-flat-neutron-provider
Tags: 	     vlan,flat,neutron,provider,network,openstack,openvswitch,ovs
Status:      published

at one of my projects I was been asked to set up a private cloud for a validation platform. The whole idea behind this proof of concept is based on the flexibility to spin up and down certain instances providing some specific functionality so tests banks can be ran against them.

As soon as the tests are finished the machines could be terminated. Those instances should be configured using some configuration management software, like [puppet](https://puppetlabs.com/puppet/puppet-open-source). That way the instances are rebuildable and could be treated as cattle.

On the other hand, it takes about 20 minutes to build up an instance from scratch, centos minimal with a puppet run to install and configure the whole needed stack. So we looked for a workable way to spin up instances really quick without the waiting time of 20 minutes every time.

We found a workable solution with [packer](https://packer.io). By configuring a template which describes a series of steps needed to be executed to get a fully working instance based on a centos minimal cloud instance, we could provide an easy and reusable way to build our artifacts.

When running the packer command an openstack instance is launched based on a [centos cloud](http://cloud.centos.org/centos/) image. Packer will use rsync to upload some needed data directories, in our case a puppet environment. Once this step has been done a local puppet apply will be performed based on the previously uploaded puppet environment. As soon as this puppet run has been successfully executed an image will be created an immediately be uploaded to your openstack instance.

By using [vagrant](https://vagrantup.com) you could easily write your puppet code first and test it against a local vm based on [virtualbox](https://virtualbox.org) or [lxc](https://github.com/fgrehm/vagrant-lxc) containers. Once you know your puppet manifests are working on a local vm you could test it on an openstack instance using the [vagrant-openstack](https://github.com/ggiamarchi/vagrant-openstack-provider) provider. That way you could filter out some unforeseen issues without the need of running packer over and over again.

When your vagrant-openstack based instance is deployed fine packer is used to build an image of your specific device.

By spinning up an instance based on this crafted image you could gain like about 18 minutes every time you launch one since it takes about less than 2 minutes to get it up and running fully functional!

# Openstack

We used the RDO [all-in-one](https://www.rdoproject.org/Quickstart) installer to get an openstack up and running on one physical machine rather quickly (15-30 minutes for the initial services).

This openstack instance is based on [CentOS 7 minimal](https://www.centos.org/download/) since it's a requirement of the used openstack release [kilo](https://wiki.openstack.org/wiki/ReleaseNotes/Kilo).

## networking

in our case we wanted some different networking setup as from the default one with natting. Instead we wanted a [flat](https://trickycloud.wordpress.com/2013/11/12/setting-up-a-flat-network-with-neutron/) network provider so our instances have an ip within the same range as our development network. That way the natting could be kicked out of the setup to exclude some possible networking performance.

Beside this flat network we do use vlan's too, so the openstack instance should be able to route over those vlan's too. We found a similar setup on the [blog](http://www.s3it.uzh.ch/blog/openstack-neutron-vlan/) of the University of Zurich. But it lacked an underlying physical network configuration example on the all-in-one node itself.

On opencloudblog a clear [article](http://www.opencloudblog.com/?p=460) helped in trying to understand the network philosophy used to get it working.

### manual network configuration

creating the vlan bridge which is used by openstack to communicate with the physical vlan based networking switch:

```bash
ovs-vsctl add-br br-vlan
ovs-vsctl add-port br-vlan eth0
vconfig add br-vlan 100
```

configuring an ip from the development range to an interface on the node so we have access to it:

```bash
ip link set br-vlan up
ip link set br-vlan.100 up
ip address add dev br-vlan.100 192.168.0.100 netmask 255.255.255.0
ip route add default via 192.168.0.1
```

configuring openstack ml2 plugin with our vlan setup:

/etc/neutron/neutron.conf

```bash
core_plugin =neutron.plugins.ml2.plugin.Ml2Plugin
```

Configuring the actual vlan's:

/etc/neutron/plugins/ml2/ml2_conf.ini

```bash
type_drivers = vxlan,gre,vlan
network_vlan_ranges = vlan100:100:100
```

Creating the mapping between the vlan and the actual physical interface:

/etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini
```bash
bridge_mappings = vlan100:br-vlan
```

to get the metadata service usable on this flat network:

/etc/neutron/dhcp-agent.ini
```bash
enable_isolated_metadata = True
```

restarting neutron-dhcp-agent
```
# openstack-service status neutron-dhcp-agent
```

Configuring the openstack networks on the all-in-one machine:

```
# source keystonerc_admin
# neutron subnet-list
# neutron subnet-delete ID
# neutron net-list
# neutron net-delete ID
# neutron net-create vlan100 --shared --provider:network_type vlan --provider:segmentation_id 100 --provider:physical_network vlan100 --router:external
# neutron subnet-create --name vlan100 --gateway 192.168.0.1 --allocation-pool start=192.168.0.150,end=192.168.0.200 --enable-dhcp --dns-nameserver 192.168.0.1 vlan100 192.168.0.0/24
# neutron subnet-update --host-route destination=169.254.169.254/32,nexthop=192.168.0.151 vlan100
```

We do have a working setup right now if everything went well and you should be able to [launch](https://www.rdoproject.org/Running_an_instance) an instance. To test ICMP traffic do not forget to enable a security group which allows this kind of traffic. Otherwise you couldn't use ping to test traffic.


Some useful commands:

```bash
ovs-vsctl show #shows the openvswitch configuration
ovs-ofctl dump-flows br-int #shows the flows to map an internal project tag to an actual vlan id
brctl show #shows the linux bridge
```

### persistent network configuration

To keep your networking up and running after a reboot you should configure you bridges natively on the all-in-one instance:

/etc/sysconfig/network-scripts/ifcfg-eth0

```bash
DEVICE="eth0"
ONBOOT=yes
OVS_BRIDGE=br-vlan
TYPE=OVSPort
DEVICETYPE="ovs"
```

/etc/sysconfig/network-scripts/ifcfg-br-vlan

```bash
DEVICE=br-vlan
BOOTPROTO=none
ONBOOT=yes
TYPE=OVSBridge
DEVICETYPE="ovs"
```

/etc/sysconfig/network-scripts/ifcfg-br-vlan.100

``` bash
BOOTPROTO="none"
DEVICE="br-vlan.100"
ONBOOT="yes"
IPADDR="192.168.0.100"
PREFIX="24"
GATEWAY="192.168.0.1"
DNS1="192.168.0.1"
VLAN=yes
NOZEROCONF=yes
USERCTL=no
```

Be sure to use the OVSBridge type and ovs DEVICETYPES otherwise it will not work..

Something we have on our todo is the [configuration drive](http://docs.openstack.org/user-guide/cli_config_drive.html) setup. When using a configuration drive the metadata dhcp service could also be skipped and therefore possibly the whole openvswitch configuration could be passed by only using a provider network with a [linux bridge](http://docs.openstack.org/networking-guide/deploy_scenario4b.html)

[serverspec](http://serverspec.org/) were also written so the functionality of the puppet managed services are tested easily over and over to be sure the code is actually doing as it supposed to do.
