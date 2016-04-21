Title:       Openstack live-migration
Author:      Jan
Date: 	     2016-04-21 19:00
Slug:	     openstack-live-migration
Tags: 	     openstack, live, migration, kilo, kvm, block, config, drive, vfat
Status:	     published

Some of you may already have notices others just stumbled on this post through a search engine, I have setted up an openstack private cloud at one of our projects:

* [vlan flat-neutron provider network](https://visibilityspots.org/vlan-flat-neutron-provider.html)
* [layer2](https://visibilityspots.org/openstack-layer2.html)

We have noticed that the benefits of having a private cloud is spreading through the different teams within the organization and therefore the interest into this flexibility is growing. Since this wasn't the original [use case](https://visibilityspots.org/vlan-flat-neutron-provider.html) we are encountering some design issues right now.

For the original instances the default [overcommit](http://docs.openstack.org/openstack-ops/content/compute_nodes.html#overcommit) ratios are fine. But the request for new machines with other goals are like interfering with those original instances running in the same default [availability zone](http://docs.openstack.org/openstack-ops/content/scaling.html#az_s3).

So we are looking to configure some [aggregate zones](http://docs.openstack.org/openstack-ops/content/scaling.html#ha_s3) to keep this under control. As soon as we figured out a workable solution I will write about it in a new blog post.

But in the discussions to come to a solution one remark was couldn't openstack tackle those issues of having an hypervisor with a growing load and memory issues itself by migrating instances to another hypervisors? Which is like a valuable argument to me. So before even looking into such a solution the feature of live migration should work..

Since we aren't using shared storage for our cloud this could be tricky. So I went to the web to inform myself about the different options.

I came across some very interesting reads, like the one of [Thornelabs](https://thornelabs.net/2014/06/14/do-not-use-shared-storage-for-openstack-instances.html) why you shouldn't use shared storage for example. Which has some valuable disadvantages of it besides the benefits. In our use case the benefits aren't outweighing against disadvantages. But as I have noticed in the whole openstack story there are options for almost every cloud use case and therefore the logical complexity of it. So for many amongst you shared storage could be a solution.

Another rather interesting one about live migration as a [perk not a panacea](https://www.blueboxcloud.com/insight/blog-article/live-migration-is-a-perk-not-a-panacea)

One of the [options](http://docs.openstack.org/openstack-ops/content/compute_nodes.html#instance_storage) is [non shared](http://docs.openstack.org/openstack-ops/content/compute_nodes.html#on_compute_node_storage_nonshared) storage, the default of the RDO packstack installer, based on LVM. On our setup we are using this default.

This has the consequence we can only use the live migration about with the kvm block storage [migration](http://www.sebastien-han.fr/blog/2012/07/12/openstack-block-migration/) which isn't really [supported](http://osdir.com/ml/openstack-cloud-computing/2012-08/msg00293.html) by the upstream developers and will probably phased out in the future for something more reliable.

We configured [config drives](http://docs.openstack.org/user-guide/cli_config_drive.html) as the default to get the metadata served to cloud-init at boot time for an instance. The default drive format (iso9660) has a bug in libvirt of copying a read-only disk. To tackle this one we configured the vfat format on all hypervisors.

Unfortunately this still doesn't solve our issue with it. Apparently when you use the live migrate option openstack [doesn't](https://bugs.launchpad.net/nova/+bug/1214943) take the overcommit ratio into account. Since our cloud is already overcommitted we don't have enough resources according to the live migration precheck to move instances around..

The proposed fix isn't released yet in the RDO kilo nova packages and patching a system isn't something I like to do in a semi-production environment.

So until today live migration isn't something we have tackled yet on our cloud. If you have solved this on your kilo RDO release cloud already feel free to enlighten me about it!
