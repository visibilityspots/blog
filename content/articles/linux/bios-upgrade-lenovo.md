Title:       BIOS upgrade lenovo archlinux
Author:      Jan
Date:        2019-05-04 23:00
Slug:        bios-upgrade-lenovo
Tags:        linux, archlinux, bios, BIOS, upgrade, lenovo
Status:      published
Modified:    2019-05-04

I got some issues with my wired connection lately that the speed wasn't negotiated correctly and it felt back to 10Mb/s as default.

Did some troubleshooting by eliminating various network devices, restarting them but the results didn't satisfy. Being completely random when and when not auto negotiated.

Before becoming insane I decided to update the bios of my machine (being a lenovo T460s).

I did this already in the past and talked about it even on one of our monthly last Friday's at [work](https://inuits.eu). So I was quite sure I had something written about it for future reference but I couldn't find it anymore.

So I decided to write a post how I did it this time so I could refer to it for myself in the future since I don't do this regularly..

First of all you have to find out your serial number so we can download the latest bios from lenovo.

By using [dmidecode](https://www.archlinux.org/packages/extra/x86_64/dmidecode/) this can be done through your terminal
```
$ sudo dmidecode -s system-serial-number
```

This serial number can be used on the lenovo [support](https://support.lenovo.com/be/en) site, where you should find the BIOS Update (Bootable CD) iso in the list of Drivers & Software.

Once downloaded we will use [geteltorito](https://aur.archlinux.org/packages/geteltorito/) script as being described on the [ArchWiki](https://wiki.archlinux.org/index.php/Flashing_BIOS_from_Linux#Bootable_optical_disk_emulation) to extract the iso into an image file which we can copy onto an USB stick

```bash
$ geteltorito.pl -o <image>.img <image>.iso
$ lsblk -l
$ sudo dd if=<image>.img of=<destination> bs=512K
```

This USB device can now be used to boot from (during boot process press ENTER followed by F12 where you can select the USB device)

It's advised to connect your power supply and your battery has been charged about 80-100% before upgrading your BIOS.

After I had upgraded my BIOS my speed is negotiated correctly. I'm not sure if upgrading did the trick since I rebooted all the network devices where I had this issue but it works now and I have an upgraded BIOS so I'm a happy surfer again. :)

Some references:

* [https://www.cyberciti.biz/faq/update-lenovo-bios-from-linux-usb-stick-pen/](https://www.cyberciti.biz/faq/update-lenovo-bios-from-linux-usb-stick-pen/)
* [https://wiki.archlinux.org/index.php/Flashing_BIOS_from_Linux](https://wiki.archlinux.org/index.php/Flashing_BIOS_from_Linux)
* [https://workaround.org/article/updating-the-bios-on-lenovo-laptops-from-linux-using-a-usb-flash-stick/](https://workaround.org/article/updating-the-bios-on-lenovo-laptops-from-linux-using-a-usb-flash-stick/)
