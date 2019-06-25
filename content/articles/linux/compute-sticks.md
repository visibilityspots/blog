Title:       ArchLinux on intel compute stick
Author:      Jan
Date:        2019-06-24 19:00
Slug:        compute-sticks
Tags:        ArchLinux, archlinux, arch, linux, intel, compute, stick, sticks, STK1A32SC
Status:      published
Modified:    2019-06-24

A few months ago we moved into a brand new office which was furnished with a dozen of samsung displays. Unfortunately the basic player included in those displays isn't capable to add a webpage/url as content. Since we've setted up a [smashing](https://smashing.github.io/) instance to create dashboards for each team this was a huge bummer.

While looking for a stable solution many teams brought their own raspberry pi's, chromecasts, airtame devices to at least be able to show something on the displays in the meanwhile.

Since we already had good experiences with an intel compute stick and an intel NUC we decided to get and configure about 8 compute sticks model STK1A32SC with archlinux running to be able to display our dashboards.

For our stand up corners we went for 3 intel NUC's with some peripherals like a web-cam/keyboard and a jabra device to provide proper communication during the stand-ups.

But back to the compute sticks.

# Initial setup

since we had to install and configure about 8 sticks we decided to configure a base archlinux setup on one stick and using [dd](https://wiki.archlinux.org/index.php/Dd) afterwards to get the others up and running with a basic archlinux stack.

## BIOS

before we could boot a live usb archlinux distro we had to change the operating system setting in the bios to Android

```
boot device
press F2
-> Select Operating System
-> Android
```

once that's done and you've rebooted press F10 to boot from the live USB distro

## basic setup following guide

use wifi-menu command to connect to your wireless network to get some network connectivity first

following the basic [installation guide](https://wiki.archlinux.org/index.php/Installation_Guide) we went for an UEFI setup with a [GPT partitioned](https://wiki.archlinux.org/index.php/EFI_system_partition#GPT_partitioned_disks) disk.

and opted for this layout where 20G is reserved for the root partition, 7.6G as var and 1G for swap.

#### partition layout

```
Device            Start      End  Sectors  Size Type
/dev/mmcblk0p1     2048  1050623  1048576  512M EFI System
/dev/mmcblk0p2  1050624  3147775  2097152    1G Linux swap
/dev/mmcblk0p3  3147776 45090815 41943040   20G Linux filesystem
/dev/mmcblk0p4 45090816 61071326 15980511  7.6G Linux filesystem
```

We configured [grub](https://wiki.archlinux.org/index.php/GRUB#Generate_the_main_configuration_file) assuming the EFI partition being mounted as boot and chrooted using arch-chroot as being explained in the installation guide.

```
# grub-install --target=x86_64-efi --efi-directory=boot --bootloader-id=GRUB
```

#### tools

some tools we preinstalled where the SSH daemon along with an authorized key for a specific user and python to be able to run ansible afterwards.

also we configured the wireless network already using [systemd-network](https://wiki.archlinux.org/index.php/Systemd-networkd)

This besides the preferred stuff which is described in the installation guide.

when everything is installed through the installation guide using arch-chroot you can go ahead and reboot

## reboot

when you have rebooted you should now enter the Grub to the installed archlinux distribution based on the disk of the compute stick. Once that's working fine you can go ahead.

# create an image with dd on separate stick

as soon as you got a working compute stick you can reboot and now use the live usb distro again

```
# wifi-menu
# systemctl start sshd.service
# passwd
```

now try to ssh into the live distro from another machine so you could unplug the keyboard and use that second USB port to connect an empty USB drive to store the image on.

```
# lsblk
NAME         MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
loop0          7:0    0 500.8M  1 loop /run/archiso/sfs/airootfs
sda            8:0    1  14.5G  0 disk
├─sda1         8:1    1   614M  0 part /run/archiso/bootmnt
└─sda2         8:2    1    64M  0 part
sdb            8:16   1  28.9G  0 disk
└─sdb1         8:17   1  28.9G  0 part
mmcblk0      179:0    0  29.1G  0 disk
mmcblk0boot0 179:8    0     4M  1 disk
mmcblk0boot1 179:16   0     4M  1 disk
```

mount the additional USB drive and start creating an image through a screen session

```
# mount /dev/sdb1 /mnt
# screen -S image-creation
# dd if=/dev/mmcblk0 conv=sync,noerror bs=64K status=progress | gzip -c > /mnt/base-image-dashboards.img.gz
```

# restore image

to restore the image on a new compute stick you have to boot again in live distro mode and enable wifi + ssh to be able to unplug the keyboard USB port once again

```
# wifi-menu
# systemctl start sshd.service
# passwd
```

```
# lsblk
NAME         MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
loop0          7:0    0 500.8M  1 loop /run/archiso/sfs/airootfs
sda            8:0    1  14.5G  0 disk
├─sda1         8:1    1   614M  0 part /run/archiso/bootmnt
└─sda2         8:2    1    64M  0 part
sdb            8:16   1  28.9G  0 disk
└─sdb1         8:17   1  28.9G  0 part
mmcblk0      179:0    0  29.1G  0 disk
mmcblk0boot0 179:8    0     4M  1 disk
mmcblk0boot1 179:16   0     4M  1 disk
```

next mount the USB drive with the base image on
```
# mount /dev/sdb1 /mnt
# ls /mnt
base-image-dashboards.img.gz  lost+found
```

then start a screen session to unpack the image to the disk of the compute stick
```
# screen -S restore
# gunzip -c /mnt/base-image-dashboards.img.gz | dd of=/dev/mmcblk0 status=progress
```

and last but not least initiate grub to install the UEFI partition
```
# mount /dev/mmcblk0p3 /mnt                                                                                                                                                                                                                                 :(
# mount /dev/mmcblk0p1 /mnt/boot
# mount /dev/mmcblk0p4 /mnt/var

# arch-chroot /mnt

# grub-install --target=x86_64-efi --efi-directory=boot --bootloader-id=GRUB
Installing for x86_64-efi platform.
Installation finished. No error reported.

# exit

# umount -R /mnt
# reboot
```

the compute stick should now boot into the new ArchLinux distribution installed on it's disk and can be configured using ansible.

# kiosk mode

the main goal of our use case was to show an url. First idea was to use [luakit](https://luakit.github.io/) as a browser. But luakit isn't available in the official repositories and isn't able to rotate different tabs.

So we went for chromium which is started [without a window-manager](https://wiki.archlinux.org/index.php/Xinit#Starting_applications_without_a_window_manager) and [nodm](https://wiki.archlinux.org/index.php/Nodm) to automatically start an x session at boot.

Some quirks we had to resolve where the disabling of the auto restore of chromium by altering the Default/Preference file and setting the values of exit_type to none and exited_cleanly to true after which we made the file read only by making it immutable with the chattr command.

The other one is the installation of the tabcarrousel plugin which we are still looking how we can automate this configuration with ansible.
