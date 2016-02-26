Title:       Openstack layer2
Author:      Jan
Date: 	     2016-02-26 20:30
Slug:	     openstack-layer2
Tags: 	     openstack, layer2, security, groups, linux, bridge, ovs, open, vswitch, dhcp
Status:	     published

A few months ago I implemented an RDO based openstack private cloud at one of our customers for their development platform. Through time we tackled a couple of issues so the cloud could be fitted into their work flows.

We stumbled onto some minor issues and some major ones. Let's begin with the minor ones ;)

When upgrading the all-in-one controller before we started using the cloud in 'production' a mean [bug](https://bugzilla.redhat.com/show_bug.cgi?id=1284978) bit us in the ankle due to a new hiera package. After some digging around a [patch](https://review.openstack.org/#/c/249301/3/packstack/modules/ospluginutils.py) came to the rescue together with the exclusion of the packages puppet* and hiera* from the epel repository

```
vim /etc/yum.repos.d/epel.repo +9
exclude=hiera*,puppet
```

Once launched some rather irritating behavior seemed to be the default timeout of horizon (openstack-dashboard) of 30 minutes. It's a development cloud after all and people didn't wanted to re login all the time. To change the default timeout we added a SESSION_TIMEOUT parameter to the local_settings file and restarted apache

```
vim /etc/openstack-dashboard/local_settings
SESSION_TIMEOUT = 28800

systemctl restart httpd
```

After which we reconfigured the expiration time of the keystone token and restarted the keystone service

```
vim /etc/keystone/keystone.conf
expiration = 28800

systemctl restart openstack-keystone.service
```

Another rather tiny issue was the access to the console through the web interface. It couldn't connect through the instance when running on another compute node.

After some research it seemed to by DNS. In the development setup no DNS has been configured for the different compute nodes. We tackled it by the proxy client setting in nova.conf on every compute node

```
vim /etc/nova/nova/conf
vncserver_proxyclient_address=actual.ip.of.the.server
```

During maintenance we had to reboot a compute-node, after this reboot the instances living on the compute node where not started and came up in shutdown state.

It seemed to be the default behavior of openstack, but as always there is a configuration parameter for it to force the instances to start after a reboot.

```
vim /etc/nova/nova.conf
resume_guests_state_on_host_boot=true
```

The default behavior of the kilo RDO deployed cloud to pass data through cloud-init to the instance is by serving the file through a separate network at boot time.

We however found it more efficient to serve this file through the filesystem, the so called [config_drive](http://docs.openstack.org/user-guide/cli_config_drive.html) option.

It can be forced through the nova config file

```
vim /etc/nova/nova.conf
force_config_drive=True
```

Also be aware with the lock_passwd feature with passing users through cloud init in openstack: https://bugs.launchpad.net/cloud-init/+bug/1521554

So now the minor issues are tackled let's switch to the major and more impacting ones.

We digged into the behavior of the network during the proof of concept phase. And hell that's a big challenge! By default openstack neutron creates a linux bridge and an open vswitch bridge.

The linux bridge is used to translate the security groups into iptables configured to the linux bridge interfaces.

In our use case we wanted to keep the networking setup as simple as possible. Mainly cause a lot of the instance will be used for testing purposes including network traffic and performance.

Since it's only used for internal usage into the R&D department on the we decided to disable the security groups and therefore to ditch the linux bridge out of the linux cluster.

Another reason to disable the security groups was the fact that by using the nova interface-attach command of a network without a subnet configured (layer2) only the default security group was applied to this extra interface.

I filled out a [bug](https://bugs.launchpad.net/neutron/+bug/1512645) for this, but it seems we are abusing a bug (attaching networks without subnet configured to an instance) as a feature.

Openstack really doesn't like you to take over control of the layer3 networking part after all. But in our use case we really needed to take over this control to keep our instances as abstract and dynamic as possible.

We only need layer2 connectivity when adding an instance to a specific VLAN based network, an ip address is provided by another DHCP server on this VLAN network. So we don't want openstack to provide DHCP addresses.

By using the nova interface-attach command and the bug/feature of having networks without subnets configured attached we achieved to meet this goal of layer2 connectivity.

So to disable the linux bridge you'll need to [disable](https://gist.github.com/djoreilly/db9c2d32a473c6643551) the security groups

```
vim /etc/nova/nova.conf
security_group_api = nova
firewall_driver = nova.virt.firewall.NoopFirewallDriver

vim /etc/neutron/plugins/ml2/ml2_conf.ini # (only on controller node)
enable_security_group = False

vim /etc/neutron/plugins/openvswitch/
firewall_driver = neutron.agent.firewall.NoopFirewallDriver
```

Last but not least some configuration parameters got changed through without we noticed probably by some misconfigured settings in [packstack](https://wiki.openstack.org/wiki/Packstack). To keep this under control we made the configuration files immutable so they could only be modified by manual changes.

```
chattr +i /etc/neutron/plugins/ml2/ml2_conf.ini # (only on controller node)
chattr +i /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini
chattr +i /etc/nova/nova.conf
chattr +i /etc/neutron/policy.json
```

Those are about the main issues worth mentioning we went through. By sharing those I hope to help others in their quest to tame the openstack cluster. If any question arise feel free to comment or contact me about them!
