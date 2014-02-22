Using EID certificate on chromium
#################################
:date: 2013-05-29 19:00
:author: Jan
:tags: fedora, linux, eid, fod, belgium, chrome, chromium, browser
:slug: chrome-eid

During this time of the year in Belgium most people needs to fill in their taxes forms. Since a few years the belgium government provided an electronic way to accomplish this task. Using a digital passport you can authenticate yourself. Since I wanted to use this nice tool I had to configure my local setup to have it all glued together on my linux machine.

The necessary steps I described in this post so other interested people can user there linux setups also to fill in their tax forms.

The mayor package to install on a fedora machine is the `eid-mw`_ package:

::
	
	$ wget https://eid-mw.googlecode.com/files/eid-mw-4.0.0-0.925.fc16.x86_64.rpm
	$ sudo rpm -Uvh eid-mw-4.0.0-0.925.fc16.x86_64.rpm

Once you've installed this package and you are using firefox you should already be able to login to your `myfin`_ profile. 

You can also use the `eid-viewer`_ package, which provides you with a graphical piece of software so you can read out your passport, printing it out. Testing your pin code (if you forgot you're pincode you still have to go to your town services.

::
	
	$ wget https://eid-viewer.googlecode.com/files/eid-viewer-4.0.0-0.52.fc16.x86_64.rpm
	$ sudo rpm -Uvh eid-viewer-4.0.0-0.52.fc16.x86_64.rpm

Once the installation finished successfully you can run the software to view your information's

::
	
	$ eid-viewer

Still I'm not using firefox but the `chromium-browser`_ to accomplish than I had to add the eid interface into the chromium security settings. I found an `explanation`_ on google code and copied those steps into this post to be completed.

::
	
	$ sudo yum install nss-tools
	$ killall chromium-browser
	$ cd
	$ modutil -dbdir sql:.pki/nssdb/ -add "Belgium eID" -libfile /usr/lib/libbeidpkcs11.so.0
	$ modutil -dbdir sql:.pki/nssdb/ -list

Resources:

- `eid-belgium`_ 

.. _eid-mw: https://code.google.com/p/eid-mw/
.. _myfin: https://eservices.minfin.fgov.be/portal/nl/public/citizen/welcome
.. _eid-viewer: https://code.google.com/p/eid-viewer/
.. _chromium-browser: http://www.chromium.org
.. _explanation: https://code.google.com/p/eid-mw/wiki/ChromeLinux
.. _eid-belgium: http://eid.belgium.be/nl/je_eid_gebruiken/de_eid-middleware_installeren/linux/
