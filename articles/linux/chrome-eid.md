Title:       Chromium eid
Author:      Jan
Date: 	     2013-05-29 19:00
Slug:	     chromium-eid
Tags:        archlinux, fedora, linux, eid, fod, Belgium, chrome, chromium, browser
Status:      published
Modified:    2015-06-02 22:00

During this time of the year in Belgium most people needs to fill in their taxes forms.

Since a few years the Belgium government provided an electronic way to accomplish this task. Using a digital passport you can authenticate yourself.

I wanted to use this nice tool so I had to configure my local setup to have it all glued together on my linux machine.

The necessary steps I described in this post so other interested people can use their linux setups also to fill in the tax forms.

# Installation

The mayor package to install on a fedora machine is the [eid-mw](https://code.google.com/p/eid-mw/) package:

```bash
  $ wget https://eid-mw.googlecode.com/files/eid-mw-4.0.0-0.925.fc16.x86_64.rpm
  $ sudo rpm -Uvh eid-mw-4.0.0-0.925.fc16.x86_64.rpm
```

If you are using archlinux on a dell latitude e6530 you can use the internal card reader by installing the drivers of the [Common Access Card](https://wiki.archlinux.org/index.php/Common_Access_Card)

```bash
  $ sudo pacman -S pcsclite
  $ sudo vim /etc/opensc.conf
```

In the opensc.conf file you need to uncomment the setting _enable_pinpad = false_ on two places before you enable the process at boot and run it:

```bash
  $ sudo systemctl enable pcscd
  $ sudo systemctl start pcscd
```


So you could install the [eid-mw package](https://aur.archlinux.org/packages/eid-mw) from the AUR repository

```bash
  $ yaourt eid-mw
```

Once you've installed the [eid-mw](https://code.google.com/p/eid-mw/) package on fedora and configured the pcscd service on archlinux you could install the firefox eid [addon](https://addons.mozilla.org/en-US/firefox/addon/belgium-eid/) if you are using the firefox browser. Once that's accomplished you could test if it all works using the [test page](http://test.eid.belgium.be/) provided by the Belgium government.

You can also use the [eid-viewer](https://code.google.com/p/eid-viewer/) package, which provides you with a graphical piece of software so you can read out your passport, printing it out. Testing your pin code (if you forgot you're pincode you still have to go to your town services.

For fedora

```bash
  $ wget https://eid-viewer.googlecode.com/files/eid-viewer-4.0.0-0.52.fc16.x86_64.rpm
  $ sudo rpm -Uvh eid-viewer-4.0.0-0.52.fc16.x86_64.rpm
```

For archlinux install the [eid-viewer package](https://aur.archlinux.org/packages/eid-viewer/)

```bash
  $ yaourt eid-viewer
```

Once the installation finished successfully you can run the software to view the information of your passport

```bash
  $ eid-viewer
```

Still I'm not using firefox but the [chromium-browser](http://www.chromium.org) to accomplish than I had to add the eid interface into the chromium security settings. I found an [explanation](https://code.google.com/p/eid-mw/wiki/ChromeLinux) on google code and copied those steps into this post to be completed.

```bash
  $ # only for fedora install nss-tools
  $ sudo yum install nss-tools

  $ killall chromium-browser
  $ cd
  $ modutil -dbdir sql:.pki/nssdb/ -add "Belgium eID" -libfile /usr/lib/libbeidpkcs11.so.0
  $ modutil -dbdir sql:.pki/nssdb/ -list
```

So if you now start your chromium browser you could [test](http://test.eid.belgium.be/) if it all works on your machine too :)

# Troubleshooting

Since I only use this eid once a year and my system evolves in the meantime by installing rolling updates obviously issues arise..

```
  modutil: function failed: SEC_ERROR_LEGACY_DATABASE: The certificate/key database is in an old, unsupported format.
```

To solve his one I had to recreate my key database

```bash
  $ mv .pki/nssdb .pki/nssdb.BAK
  $ mkdir .pki/nssdb
  $ modutil -N -d .pki/nssdb/
  $ modutil -create -dbdir .pki/nssdb/
  $ certutil -L -d .pki/nssdb/
  $ modutil -dbdir sql:.pki/nssdb/ -add "Belgium eID" -libfile /usr/lib/libbeidpkcs11.so.0
  $ certutil -L -d .pki/nssdb/ -h "all"
  $ certutil -L -d .pki/nssdb/
```

When I achieved doeing so I could go ahead once again and fill in my taxes.

Resources:

- [eid-belgium](http://eid.belgium.be/nl/je_eid_gebruiken/de_eid-middleware_installeren/linux/)
