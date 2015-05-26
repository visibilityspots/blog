CPAN rpm packages
#################
:date: 2013-10-05 14:00
:author: Jan
:tags: cpan, spec, rpm, package, packaging, centos, yum, repository, cpanspec, rpmbuild
:slug: cpan-rpm-packages
:status: published

I went crazy from perl and the installation of their modules. For some icinga checks we need to install a few base perl packages using `cpanminus`_. It's taking a long time before the installation succeeds depending on the internet connection or server specifications.

Using a puppet exec to automate this installation is frustrating because the timeout is unpredictable and could take hours from time to time!

So I started to look for a way to package it into an rpm which I can distribute over our own yum repository.

The first software I got reviewed is `cpan2rpm`_, it looked promising. You could give a text file containing the names of the modules to package.

That way I could use a git repo containing this file which triggers an automated `jenkins`_ job which creates the packages and uploads them to the repo.

Unfortunately it doesn't package the cpanminus module. So I had to look further.

Last week I got the solution by `cpanspec`_, a piece of software I read about on `nailingjelly`_ 's blogpost. And yes, I achieved to package it.

Installation & configuration of the required tools:

::

	$ sudo yum install rpmdevtools perl perl-devel perl-Test-Base
	$ sudo curl -L http://cpanmin.us | perl - --sudo App::cpanminus
	$ sudo /usr/local/bin/cpanm CPAN::DistnameInfo
	$ sudo yum install cpanspec

	$ cd ~
	$ rpmdev-setuptree

Create spec file and source rpm from a cpan module:

::

	$ cpanspec --follow --srpm CPAN::Module --packager YOURNAME

Install the source rpm to create a package from it using the new generated spec file:

::

	$ rpm -i name-of-module.src.rpm

You should see there is a SPEC file generated in the rpmbuild tree:

::

	$ cd ~/rpmbuild/SPECS
	$ vim cpan-module-name.spec

Finally give it a shot and build a fresh rpm package:

::

	$ rpmbuild -ba cpan-module-name.spec

The first time trying to build App::cpanminus I had to add some missing file declarations to the spec file. Spawning the error:

::

	RPM build errors:
	    Installed (but unpackaged) file(s) found:
            /usr/bin/cpanm
            /usr/share/man/man1/cpanm.1.gz

So I added the 2 unpacked files to the %files section:

::

	%files
	%defattr(-,root,root,-)
	%doc Changes cpanfile LICENSE META.json README
	%{perl_vendorlib}/*
	%{_mandir}/man3/*
	/usr/bin/cpanm
	/usr/share/man/man1/cpanm.1.gz

Running the rpmbuild now resulted in a fresh rpm:

::

	$ ls ../RPMS/noarch/
 	perl-App-cpanminus-1.7001-1.el6.noarch.rpm

I installed the rpm on a development system and successfully installed a perl module with the cpanm command afterwards:

::

	$ yum localinstall name-of-the-module.rpm

So from now on our servers are hooked up with those create packages distributed by our own yum repository.

And the whole initialization process of a fresh server gained in time and therefore in efficiency in our environment this way!

Resources:

-  `nailingjelly`_
- `man`_ cpanspec
-  Centos.org `wiki`_

.. _cpanminus: http://search.cpan.org/~miyagawa/App-cpanminus-1.7001/lib/App/cpanminus.pm
.. _cpan2rpm: http://perl.arix.com/cpan2rpm/
.. _jenkins: http://jenkins-ci.org/
.. _cpanspec: https://github.com/silug/cpanspec
.. _wiki: http://wiki.centos.org/HowTos/RebuildSRPM
.. _nailingjelly: http://nailingjelly.wordpress.com/2009/06/03/cpan-rpm-packaging/
.. _man: http://cpanspec.sourceforge.net/cpanspec.1.html
