Upgrade to puppet 3.3.0
#######################
:date: 2013-09-20 19:00
:author: Jan
:tags: puppet, upgrade, 3.3.0, 2.6.x, issues, foreman, passenger, puppetdb
:slug: puppet-3-upgrade
:status: published

I finally got to the point where I upgraded a whole puppet infrastructure from puppet 2.6.x to the last stable version of puppet, `3.3.0`_. And after finding out the way to go it was surprisingly easy and no big issues came across.

One of the main reasons to upgrade was to start using the latest version of foreman, were we used 0.4, so we can start provisioning our own development vm's with some fancy cloud solution like for example `cloudstack`_ using our production puppet tree.

Before the upgrade we had the puppet-client & server (2.6.18), puppetdb (1.4), (ruby 1.8.7) and foreman (0.4.2) running on a CentOS 6.3 machine.

After upgrading we are running puppet-client & server (3.3.0) puppetdb (1.4), ruby (1.8.7) and foreman (1.2) all managed by puppet itself. (feels quite satisfying ;) )

The very fist time I started upgrading the puppet master, but instead of upgrading the puppet-server package from the yum puppetlabs repository I upgraded only the agent.

After I figured that out I could kill myself but ran out of time so needed to stop the process.

The second time I started totally in the wrong direction. I started with foreman, read about needing ruby 1.9.3. So I started looking for a CentOS 6.3 ruby 1.9.3 package.

Didn't find any started compiling it from source, but that came out on a total mess so I reverted my upgrade and postponed it for some days.

The final 3Th time I started in the right order. This order I will describe here:

(Before all those steps, make sure to disable puppet on your clients to have more control during the process)

Configuring the puppetlabs repository
-------------------------------------

I like to install software from packages, so I started by configuring the `puppetlabs`_ repository. I use a puppet-repo module for configuring repo's on our machines but you can quite easy install it from the command line.

This command is executed on a Cent0S 6.3 x86_64 machine:

::

	# rpm -ivh http://yum.puppetlabs.com/el/6.0/products/x86_64/puppetlabs-release-6-7.noarch.rpm

Upgrading the puppetmaster
--------------------------

So after shamelessly updated only the puppet package the first time, this time I did upgrade the puppet-server package without any issue. Be sure to read the `docs`_ first about upgrading!

::

	# yum update puppet-server

Once the puppetmaster is updated we can try our first puppet runs against the upgraded version.

Start a native puppet master process for testing
------------------------------------------------

Before I get further in our upgrade process on passenger and stuff I wanted to know if the client is still able to do a puppet run without the passenger setup.

So I had to start the puppetmaster as a daemon, did a local puppet noop run on the master itself and stopped the puppetmaster daemon after I checked the run.

::

	# puppet resource service puppetmaster ensure=running enable=true
	# puppet agent --test --noop
	# puppet resource service puppetmaster ensure=stopped enable=true

Upgrade the passenger setup
---------------------------

We are using a passenger setup to have our puppet master in a scalable setup. Therefore we also needed to upgrade passenger on our puppetmaster and adopt the puppetmaster vhost to the upgraded environment.

To accomplish this I simply followed the `passenger`_ documentation of puppetlabs which was quite easy to follow.

Client
------

Once the puppetmaster was upgraded I tested a puppet run with a still not updated client against the upgraded puppetmaster. It did the job except from sending reports. Since I planned to upgrade the clients too I did not invest time into this issue.

There fore I just upgraded the client itself where the puppetlabs repository already was enabled:

::

	# yum update puppet

Issues
------

+ 403: authentication error

By running my first 3.3.0 client vs the 3.3.0 master I got an authentication error 403 forbidden request. Did some research on the net, and found about an issue in the puppetmaster's `auth.conf`_ file. Once I added this to the file:

::

	# allow nodes to retrieve their own node definition
	path ~ ^/node/([^/]+)$
	method find
	allow $1

The run did what I had to do configuring the server by using puppet!

+ undefined method 'symbolize'

On some clients I got this error message when trying to run puppet. On `somethingsinistral.net`_ I found out it had to see with multiple puppet versions on your machine. By looking into the installed gems (make sure to check also possible rvm environments) and cleaned the ancient ones out I got the puppet run up and running again.

+ icinga `check_puppet`_

We are using ripienaar's icinga check_puppet to monitor the puppet functionality. The became all red indicating puppet had too long not ran on the server. In the troubleshooting process I figured out the nagios user which is running the check over the NRPE protocol wasn't able to read the /var/lib/puppet/state/last_run_summary.yaml file. By checking permissions I found out the default settings of the /var/lib/puppet directory are 0750 when installing puppet.

Once I've changed them to 755 all check's became green again!

Foreman
-------

Once the puppet master was running fine again I also upgraded `theforeman`_ service running on the same machine as the puppetmaster. This went smoothly once I figured out the ruby and rake commands in the documentation must be replaced with ruby193-rake/ruby193-ruby when installed foreman from their repository.

Also do not forget to install foreman-mysql / foreman-sqlite etc when using those extra features.

.. _3.3.0: http://docs.puppetlabs.com/puppet/3/reference/release_notes.html
.. _cloudstack: http://cloudstack.apache.org/
.. _docs: http://docs.puppetlabs.com/guides/upgrading.html
.. _puppetlabs: http://docs.puppetlabs.com/guides/puppetlabs_package_repositories.html
.. _passenger: http://docs.puppetlabs.com/guides/passenger.html
.. _auth.conf: http://projects.puppetlabs.com/issues/16765
.. _somethingsinistral.net: http://somethingsinistral.net/blog/the-angry-guide-to-puppet-3/
.. _check_puppet: https://github.com/ripienaar/monitoring-scripts/issues/3
.. _theforeman: http://theforeman.org/manuals/1.2/index.html#3.3InstallFromPackages
