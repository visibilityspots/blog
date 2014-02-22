CentOS 6.4 software raid & LVM
##############################
:date: 2013-07-24 23:00
:author: Jan
:tags: software, raid, softwareraid, lvm, mdadm, centos
:slug: raid

Been asked to setup a software raid of 12TB on a minimal CentOS 6.4 installation with 5 disks of 3TB each. Never played with raid nor lvm before so the challenge was great!

I started by doing research about `RAID`_. Came to the conclusion that RAID 5 was the best option for our purpose. So kept looking for a way to implement a software raid and stumbled into `mdadm`_.

Using the information of `Richard`_'s and `Zack Reed`_'s blogs I easily setted up the raid array and created some lvm volumes on top of that.

Creating of 3TB partitions on the physical disks

::

	# parted /dev/sdX
	# (parted) mklabel gpt
	# (parted) unit TB
	# (parted) mkpart primary 0.00TB 3.00TB
	# (parted) print

Creating the raid5 array with all the prepared disks

::

	# mdadm --create /dev/md0 --level=raid5 --raid-devices=5 /dev/sdX# /dev/sdX# /dev/sdX# /dev/sdX# /dev/sd#

Viewing the state of creation of the new array

::

	# watch cat /proc/mdstat

Once the array is successfully created you have to store it into the config file

::

	# echo "DEVICE partitions" > /etc/mdadm.conf
	# echo "MAILADDR root@localhost" >> /etc/mdadm.conf
	# mdadm --detail --scan >> /etc/mdadm.conf

so we can start creating lvm volumes on top of them

::

	# pvcreate /dev/md0
	# vgcreate vg_NAME /dev/md0
	# lvcreate --name lv_NAME -l 100%FREE vg_NAME

We now created a physical volume, a volume group and a logical volume which can easily be resized and moved on top of the raid5 setup

To start using the volume we finally have to create a file system on it and check if everything went alright

::

	# mkfs.ext4 /dev/vg_NAME/lv_NAME
	# fsck.ext4 -f /dev/vg_NAME/lv_NAME

After the succesfull file system chack I came to a working raid setup. Nevertheless I figured out that by rebooting the machine the raid array wasn't initializing as I expected. Instead of the md0 as configured the raid array was coming up as a read-only one named md127. I did some research and found a usefull topic on it on the redhat `bugzilla`_ forum.

There I found out that this can be reactivated manually by stopping the read-only instance and reassambling the array based on the /etc/mdadm.conf file:

::

	# mdadm --stop /dev/md172
	# mdadm --assemble --scan

Although that's not really the best solution because you have to do this by every reboot of your system. So I looked a bit further and found out you can regenerate your initramfs image using your mdadm.conf file using dracut:

::

	# mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).img.old
	# dracut --mdadmconf --force /boot/initramfs-$(uname -r).img $(uname -r)

Once that images is build I successfully rebooted the system and the md0 came up without any problem.

The final step is to get the new logical volume  mounted automatically at boot, therefore you have to add something in your /etc/fstab file:

::

	# /dev/mapper/vg_NAME-lv_NAME /var/NAME ext4 defaults 1 1


Some useful commands

::

	## Stop raid array
	# mdadm --stop /dev/md0

	## Start raid array
	# mdadm --assemble --scan

Resources:

- tcpdump: `removing`_
- tcpdump: `restarting`_
- `cheat`_ sheet
- raid `states`_
- `howtoforge`_ initramfs 

.. _RAID: http://www.cyberciti.biz/tips/raid5-vs-raid-10-safety-performance.html
.. _mdadm: http://linux.die.net/man/8/mdadm
.. _Richard: http://richard.blog.kraya.co.uk/2012/04/27/3tb-hdd-raid5-centos-6-2/
.. _Zack Reed: http://zackreed.me/articles/48-adding-an-extra-disk-to-an-mdadm-array
.. _removing: http://www.tcpdump.com/kb/os/linux/removing-raid-devices.html
.. _restarting: http://www.tcpdump.com/kb/os/linux/starting-and-stopping-raid-arrays.html
.. _cheat: http://www.ducea.com/2009/03/08/mdadm-cheat-sheet/
.. _states: https://wiki.xkyle.com/Mdadm#Pause_a_Verify_or_Rebuild
.. _howtoforge: http://www.howtoforge.com/how-to-create-a-raid1-setup-on-an-existing-centos-redhat-6.0-system
.. _bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=606481
