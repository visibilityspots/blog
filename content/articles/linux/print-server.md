Title:       Archlinux ARM pi zero cups network print server
Author:      Jan
Date:        2018-12-26 19:00
Slug:        print-server
Tags:        cups, pi, zero, w, print, server, archlinux, arm, sane, scan, remote, scanimage, hp, samsung
Status:      published
Modified:    2021-03-18

## Printing

Probably like many amongst us the time of the Christmas holidays is perfect to get some IT related stuff back on track. I used to have a print server setup which got broken over time and I didn't found the energy to invest time into fixing it. But the pressure became higher and higher.
111
From both my wife and daughter, especially during the holidays where the wife want to use it to print out tickets and the daughter want to print out color plates..

So during one of the evenings I pulled myself together and installed [ArchLinux ARM](https://archlinuxarm.org/) on a pi zero w and went through the following configuration.

First off all install and configure cups on the pi zero following the [Arch wiki](https://wiki.archlinux.org/index.php/CUPS)

Do not configure any printer yet, only install cups. When following the guide you can also set cups to be [available](https://wiki.archlinux.org/index.php/CUPS/Printer_sharing#Remote_administration) on our local network through the browser on port 631;

```
# vim /etc/cups/cupsd.conf
# Only listen for connections from the local machine.
#Listen localhost:631
Port 631
Listen /run/cups/cups.sock
```

```
# Restrict access to the server...
<Location />
  Order allow,deny
  Allow from @LOCAL
</Location>

# Restrict access to the admin pages...
<Location /admin>
  Order allow,deny
  Allow from @LOCAL
</Location>

# Restrict access to configuration files...
<Location /admin/conf>
  AuthType Default
  Require user @SYSTEM
  Order allow,deny
  Allow from @LOCAL
</Location>
```

Once that's done you can start the cups service and enable it to start at boot;

```
# systemctl start cups.service
# systemctl enable cups.service
```

Next we will configure the USB connected printers as raw on the pi.

first get your printer USB handle
```
# lpinfo -v | grep usb:
direct usb://Samsung/CLP-310%20Series?serial=################
```

add a new printer with the found USB handle
```
# lpadmin -p Visibilityspots-LaserJet -v usb://Samsung/CLP-310%20Series?serial=##################
# lpstat -p Visibilityspots-LaserJet -l
printer Visibilityspots-LaserJet disabled since Mon Dec 24 20:51:24 2018 -
	reason unknown
```

enable the printer
```
# cupsenable Visibilityspots-LaserJet
# lpstat -p Visibilityspots-LaserJet -l
printer Visibilityspots-LaserJet is idle.  enabled since Mon Dec 24 20:51:54 2018
```

make the printer accept jobs
```
# cupsaccept Visibilityspots-LaserJet
```

We do have a server now which can accept print jobs.

But before sending print request we need to configure our clients too. Since we configured a raw printer we need to install the printer drivers on the clients. Depending on you distribution you need to install some specific packages for the specific print drivers for your printer.

I on my ArchLinux I had to install the packages samsung-drivers for my samsung printer and hplib for the hp one.

To get the printers configured I just used the cups web interface on my machine and used the URI *http://IP-ADDRESS-PRINT-SERVER-ON-A-PI:631/printers/Visibilityspots-DeskJet* in combination with the driver for the specific model.

After that I could easily print the common know print test page which magically printer the tux!!

## Scan

Besides printing I also wanted to enable the scan option on one of the dives over the network.

This was rather easy as being described on the [ArchWiki](https://wiki.archlinux.org/index.php/Sane#Sharing_your_scanner_over_a_network) after I installed both sane and hp-lib on the print-server too.

Do not forget to enable the saned.socket systemd service on your print-server!

```
$ sudo systemctl enable saned.socket
```

And now I'm able to put something in the scanner bed and execute a custom scan function I wrote in my zsh config

```
$ scan test-image
```

zsh config:

```
scan () {
	scanimage --device "net:IP-ADDRESS-PRINT-SERVER-ON-A-PI:hpaio:/usb/Deskjet_F4100_series?serial=#################" --resolution 600 -p | pnmtops | ps2pdf - "$1.pdf"
    }
```

which creates a pdf file in the current directory based on the scanned file.

So yipeeyayee I do now have again a working network based print/scan setup without too much effort and still using our old offline printer setups!!


references:

* [https://stackoverflow.com/questions/26329186/creating-a-raw-printer-queue-in-cups-host-and-adding-them-through-cups-client](https://stackoverflow.com/questions/26329186/creating-a-raw-printer-queue-in-cups-host-and-adding-them-through-cups-client)
* [https://forum.manjaro.org/t/how-to-set-up-a-remote-printer-which-is-attached-to-a-raspberry-pi-or-any-other-arm-computer/57056y](https://forum.manjaro.org/t/how-to-set-up-a-remote-printer-which-is-attached-to-a-raspberry-pi-or-any-other-arm-computer/57056y)
