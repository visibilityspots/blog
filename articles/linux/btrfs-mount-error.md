Title:       Btrfs mount issue
Author:      Jan
Date: 	     2015-09-07 19:00
Slug:	     btrfs-mount-issue
Tags: 	     btrfs, mount, issue, error, transid, restore, recover, open_ctree, failed
Status:      published

I decided to bootstrap my new machine with btrfs as filesystem instead of ext4 LVM volumes. By following the excellent arch-wiki [btrfs page](https://wiki.archlinux.org/index.php/Btrfs) I successfully crafted a base system with sub volumes, limited on size and snapshots enabled.

Everything went fine, installed all the other stuff I needed, pulled in my data and was ready to go.

Obviously on that very moment disaster happened.. Due to an unexpected interrupt the journal went corrupt. When trying to boot I got stuck right after decrypted the disk failing to mount my btrfs root volume.

Uncool, unpleasant, .. I almost got insane..

So back to the live usb arch Linux, decrypted my disk:

```
# cryptsetup luksOpen /dev/sda2
```

and tried to manually mount the root volume

```
# mount /dev/mapper/root /mnt
```

which resulted in some error like:

```
parent transid verify failed on 109973766144 wanted 1823 found 1821
parent transid verify failed on 13891821568 wanted 540620 found 541176
parent transid verify failed on 13891821568 wanted 540620 found 541176
parent transid verify failed on 13891821568 wanted 540620 found 541176
parent transid verify failed on 13891821568 wanted 540620 found 541176
btrfs: open_ctree failed
```

Crawling through so many forum posts, stack overflow, blogposts a lot of solutions were suggested but none of them resulted in successfully mounting my brand new system..

After some time I could mount the filesystem in [recovery mode](http://ram.kossboss.com/btrfs-restore-curropt-system/)

```
# mkdir -p /mnt/root
# mount -o ro,recover /dev/mapper/root /mnt/root
```

So I decided to copy over all this data to an USB disk using rsync:

```
# mkdir -p /mnt/disk
# mount /dev/sdb1 /mnt/disk
# rsync -ah --progress /mnt/root /mnt/disk
```

Off course this took some time.. Once the data was copied over I followed the steps described by [kossboss](http://ram.kossboss.com/btrfs-transid-issue-explained-fix/):

```
# btrfs-zero-log /dev/mapper/root
# btrfsck --init-csum-tree /dev/mapper/root
# btrfsck --fix-crc /dev/mapper/root
# btrfsck --repair /dev/mapper/root
```

But no luck at all unfortunately

So I went online to the [irc #btrfs](http://irc.lc/freenode/btrfs/) channel and explained my issue. A user named darkling reached out a hand and really made my day by suggesting to mount the filesystem as [recovery](https://btrfs.wiki.kernel.org/index.php/Mount_options#Recovery) without the ro option.

```
# mount -orecovery /dev/mapper/root /mnt/root
```

And hell yeah I finally got it mounted, this recovery option did wrote a new working tree when I unmounted the filesystem so I could mount it in a normal way again!

```
# umount /mnt/root
# mount /dev/mapper/root /mnt/root
```

So I rebooted my system from live cd to hard drive and got my system back up and running!

Darkling really was my hero of the day!
