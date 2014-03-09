Using EID certificate on chromium
#################################
:date: 2013-05-29 19:00
:author: Jan
:tags: archlinux, fedora, linux, eid, fod, Belgium, chrome, chromium, browser
:slug: chrome-eid

During this time of the year in Belgium most people needs to fill in their taxes forms. Since a few years the Belgium government provided an electronic way to accomplish this task. Using a digital passport you can authenticate yourself.

Since I wanted to use this nice tool I had to configure my local setup to have it all glued together on my linux machine.

The necessary steps I described in this post so other interested people can use their linux setups also to fill in the tax forms.

The mayor package to install on a fedora machine is the `eid-mw`_ package:

.. code:: bash

        $ wget https://eid-mw.googlecode.com/files/eid-mw-4.0.0-0.925.fc16.x86_64.rpm
	$ sudo rpm -Uvh eid-mw-4.0.0-0.925.fc16.x86_64.rpm

If you are using archlinux on a dell latitude e6530 you can use the internal card reader by installing the drivers of the `Common Access Card`_

.. code:: bash

        $ sudo pacman -S pcsclite
        $ sudo vim /etc/opensc.conf

In the opensc.conf file you need to uncomment the setting '''enable_pinpad = false'''' on two places before you enable the process at boot and run it:

        $ sudo systemctl enable pcscd
        $ sudo systemctl start pcscd


So you could install the `eid-mw package`_ from the AUR repository

.. code:: bash

        $ yaourt eid-mw

Once you've installed the `eid-mw`_ package on fedora and configured the pcscd service on archlinux you could install the firefox eid `addon`_ if you are using the firefox browser. Once that's accomplished you could test if it all works using the `test`_ page provided by the Belgium government.

You can also use the `eid-viewer`_ package, which provides you with a graphical piece of software so you can read out your passport, printing it out. Testing your pin code (if you forgot you're pincode you still have to go to your town services.

For fedora

.. code:: bash

	$ wget https://eid-viewer.googlecode.com/files/eid-viewer-4.0.0-0.52.fc16.x86_64.rpm
	$ sudo rpm -Uvh eid-viewer-4.0.0-0.52.fc16.x86_64.rpm

For archlinux install the `eid-viewer package`_

.. code:: bash

        $ yaourt eid-viewer

Once the installation finished successfully you can run the software to view the information of your passport

.. code:: bash

	$ eid-viewer

Still I'm not using firefox but the `chromium-browser`_ to accomplish than I had to add the eid interface into the chromium security settings. I found an `explanation`_ on google code and copied those steps into this post to be completed.

.. code:: bash

	$ # only for fedora install nss-tools
        $ sudo yum install nss-tools

        $ killall chromium-browser
	$ cd
	$ modutil -dbdir sql:.pki/nssdb/ -add "Belgium eID" -libfile /usr/lib/libbeidpkcs11.so.0
	$ modutil -dbdir sql:.pki/nssdb/ -list

So if you now start your chromium browser you could `test`_ if it all works on your machine too :)

Resources:

- `eid-belgium`_

.. _eid-mw: https://code.google.com/p/eid-mw/
.. _eid-mw package: https://aur.archlinux.org/packages/eid-mw
.. _myfin: https://eservices.minfin.fgov.be/portal/nl/public/citizen/welcome
.. _eid-viewer: https://code.google.com/p/eid-viewer/
.. _eid-viewer package:  https://aur.archlinux.org/packages/eid-viewer/
.. _chromium-browser: http://www.chromium.org
.. _explanation: https://code.google.com/p/eid-mw/wiki/ChromeLinux
.. _eid-belgium: http://eid.belgium.be/nl/je_eid_gebruiken/de_eid-middleware_installeren/linux/
.. _Common Access Card: https://wiki.archlinux.org/index.php/Common_Access_Card
.. _addon: https://addons.mozilla.org/en-US/firefox/addon/belgium-eid/
.. _test: http://test.eid.belgium.be/
