Title:       Openstack Kilo change MTU till the VM it's tap interface
Author:      Jan
Date: 	     2017-03-23 19:00
Slug:	     openstack-mtu
Tags: 	     openstack, mtu, kilo, neutron, nova, config, ovs
Status:      published
Modified:    2017-03-23

Recently I was been asked to increase the MTU on the deployed openstack cluster at one of our customers. Since the beginning of my touch on openstack networking has been the hardest part to get my head around. In the first place because openstack does some nifty things on the networking path. But also cause for the use case at the customer a lot of customization has been done to get it implemented in their infrastructure.

Hence the shiver when the MTU question was been made..

Nevertheless together with a colleague who likes a challenge and has a profound knowledge in this area we dived into it. Starting at the external device over all the hardware network switches we came to the openstack cluster, until now nothing got in our way of increasing the MTU size. On the most of the network gear (combination of HP and Cisco) the MTU was already high enough.

But now we came to the compute nodes of our openstack cluster. We have an RDO based kilo release running with one all-in-one controller and a dozen compute nodes. We isolated the compute node where the test instance was running on and went for our dearest friend Mr google for some advise and found a very informational [pdf](https://www.openstack.org/assets/presentation-media/the-notorious-mtu.pdf) document about this topic.

After some try and error we got to the current situation where the ovs bridge has been configured with this increased MTU size together with the NIC interface of the compute node itself. This has been achieved by changing following parameters.

To change the MTU size on the ovs bridge we need veth interfaces as described in the configuration file of the plugin.

```bash
# /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini
use_veth_interconnection = True
veth_mtu = 8000
```

By restarting the neutron component on the compute node the ovs bridge got reconfigured with veth interfaces and an increased MTU size within seconds and no noticeable down time which was very convenient.

So there is only one step to achieve our goal of sending big packets over the whole chain, the tap interface of the VM on that OVS bridge.

We manually adjusted the tap interfaces by executing an ovs-vsctl command.

```bash
ip link set mtu 8000 dev PORTID
```

Unfortunately until today we didn't find a fix where a new VM gets a network connection on the OVS bridge with this increased MTU size automatically.

We tried several configurations but no luck.

As a temporary workaround we [found](http://serverfault.com/questions/680635/mtu-on-open-vswitch-bridge-port) a loop which reconfigures the MTU sizes for all available ports on an OVS bridge.

```bash
for i in $(ovs-vsctl list ports <BRIDGENAME>);do ip link set mtu 9000 dev $i;done;ip a show <BRIDGENAME>
```

The unsuccesfull changes;

```bash
# /etc/neutron/neutron.conf
advertise_mtu = True

# /etc/nova/nova.conf
network_device_mtu=8000
```

So if you did found a solution on this part, please en light us!! :)


