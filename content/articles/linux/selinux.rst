Lighttpd change tcp port in CentOS
##################################
:date: 2012-12-05 21:24
:author: Jan
:tags: centOS, lighttpd, selinux, webserver
:slug: selinux
:status: published
:modified: 2012-12-05

It seems like a very simple job, and in fact it is. But I had an issue when I tried to change this in my Cent OS 6.3 setup.

After some digging on the internet I found out selinux was the blocking factor.

The configuration of the new port has to be done in the lighttpd conf file.

/etc/lighttpd/lighttpd.conf

::

	server.port = 2080


When I changed the config file and restarted the /etc/init.d/lighttpd service I got following error:

::

	(network.c.379) can't bind to port:  2080 Permission denied

I checked that I added the port to iptables, tried other ports, nothing worked. Until I found out it was related to the default selinux configuration.

On many forums was indicated that the problem is solved by disabling the selinux service. Nevertheless I wanted to do it the right way and after some try and error found out that by installing the package policycoreutils-python you can look up the status of the selinux feature

::

	# sestatus
	SELinux status: enabled
	SELinuxfs mount: /selinux
	Current mode: enforcing
	Mode from config file: enforcing
	Policy version: 24
	Policy from config file: targeted

	# yum provides /usr/sbin/semanage
	Loaded plugins: fastestmirror, presto, priorities
	Loading mirror speeds from cached hostfile
	* base: centos.weepeetelecom.be
	* epel: be.mirror.eurid.eu
	* extras: centos.weepeetelecom.be
	* remi: remi-mirror.dedipower.com
	* updates: centos.weepeetelecom.be
	187 packages excluded due to repository priority protections
	policycoreutils-python-2.0.83-19.24.el6.x86\_64 : SELinux policy core python utilities
	Repo : base
	Matched from:
	Filename : /usr/sbin/semanage

	# yum install policycoreutils-python

Once this is done we can use the semanage command to add our new port to the selinux security feature. First we can list all already configured ports for the http service:

::

	semanage port -l \| grep http\_port\_t

If the desired port isn't listed we can add this with following command:

::

	semanage port -a -t http\_port\_t -p tcp 2080

You don't need to restart the selinux feature, the setting will take effect immediately after you added the last command. Once that is done you can restart the lighttpd service without the permission denied issue!

If you also want to have tcp port 9000 be able to work for php you also have to add this one to selinux:

::

	semanage port -a -t http\_port\_t -p tcp 9000

Sources:

-  `http://www.howtoforge.com/installing-lighttpd-with-php5-php-fpm-and-mysql-support-on-centos-6.3`_
-  `http://www.cyberciti.biz/faq/rhel-fedora-redhat-selinux-protection/`_
-  `http://www.cyberciti.biz/faq/redhat-install-semanage-selinux-command-rpm/`_

.. _`http://www.howtoforge.com/installing-lighttpd-with-php5-php-fpm-and-mysql-support-on-centos-6.3`: http://www.howtoforge.com/installing-lighttpd-with-php5-php-fpm-and-mysql-support-on-centos-6.3
.. _`http://www.cyberciti.biz/faq/rhel-fedora-redhat-selinux-protection/`: http://www.cyberciti.biz/faq/rhel-fedora-redhat-selinux-protection/
.. _`http://www.cyberciti.biz/faq/redhat-install-semanage-selinux-command-rpm/`: http://www.cyberciti.biz/faq/redhat-install-semanage-selinux-command-rpm/
