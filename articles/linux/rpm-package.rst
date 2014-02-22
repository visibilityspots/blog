Create and distribute .rpm package
##################################
:date: 2012-04-07 17:31
:author: Jan
:tags: build, new, package, repository, rpm, yum
:slug: rpm-package

You wrote a piece of software and want to distribute it on an easy way through a yum repository? That can be done, by making in the first place an rpm package of your code.

In the first place you need to set up a directory structure. This can be done using the tool rpmdevtools on a rhel based machine:
::

	# yum install rpmdevtools

Once you installed the software you need to setup the directory tree:
::

	$ rpmdev-setuptree

This will install the necessary rmpbuild directory tree.

You will see there is create a SOURCES directory, you need to get your software source into here. Best is to copy your source code into this directory named like * namoOfYourSoftware-0.0* where 0.0 stands for the release version.

Once you copied your source code you need to package it into a tar file:
::

	$ tar -cvzf nameOfYourSoftware-0.0.tar.gz namoOfYourSoftware-0.0

Once you packaged your source code we need to create a `spec file`_ in the SPEC directory.

When you created and configured your spec file the last thing we need to do is to build the actual rpm package:
::

	$ rpmbuild -ba SPECS/name.spec

If everything went smooth you should find your rpm package in the RPMS directory.

To install your rpm package to see if it actually works:
::
	
	rpm -ivh name-package.rpm

Now you have your own rpm package you can distribute. A nice and clean distribution solution could be your very own `yum repository`_

Resources:

- `hello world`_ package
- `tutorial`_ from The Linux Documentation project

.. _spec file: http://kmymoney2.sourceforge.net/phb/rpm-example.html
.. _commando: http://www.rpm.org/max-rpm/ch-rpm-install.html
.. _hello world: http://rpmfind.net/linux/rpm2html/search.php?query=hello&submit=Search+...
.. _tutorial: http://tldp.org/HOWTO/RPM-HOWTO/index.html
.. _yum repository: http://yum.baseurl.org/wiki/RepoCreate
