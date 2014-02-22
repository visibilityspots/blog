Puppet sslv3 alert certificate revoked 
#######################################
:date: 2012-10-08 11:22
:author: Jan
:tags: certificate, continuous integration, Linux, puppet, revoke, sign, ssl
:slug: puppet-revoked-certificate.rst 

I started the day with ssl issues using puppet. Last week I cleaned 2 hosts in our tree using the puppet command

::

	# puppet node clean [hostname] 

on the puppetmaster. I did this to clean out the stored configs for those nodes.

But I didn't realized this also cleaned out the ssl certificates for those clients. So I started the new week with this uncomfortable issue:

::

	[root@agent ~]# puppet agent --test err: Could not retrieve catalog from remote server: SSL_connect returned=1 errno=0 state=SSLv3 read server session ticket A: sslv3 alert certificate revoked warning: Not using cache on failed catalog err: Could not retrieve catalog; skipping run err: Could not send report: SSL_connect returned=1 errno=0 state=SSLv3 read server session ticket A: sslv3 alert certificate revoked

After some digging on the internet I achieved to solve this issue.
Here under I described the steps to breath again:

To be sure the certificates are completely removed on the puppetmaster I explicitly cleaned them again

::

	i[root@master ~]#puppet cert -c hostname

Now we are sure those certificates are cleaned up on the master we have to do this also on the agent

Looking for the directory where those certificates are stored

::

	[root@agent ~]# puppet --genconfig | grep certdir 
	# The default value is '$certdir/$certname.pem'. 
	# The default value is '$certdir/ca.pem'. certdir = /var/lib/puppet/ssl/certs

Removing the existing certificates on the client:

::

	[root@agent ~]# rm /var/lib/puppet/ssl -rf

Once the certificates are completely removed on the master and the client we have to regenerate them from the agent using the puppet daemon

::

	[root@agent ~]# puppet agent --test

or by manually regenerating them

::

	[root@agent ~]# puppet certificate generate hostname.domain --ca-location remote true

As soon as new certificates are generated and we got the true back from the agent we can sign the fresh certificate on the master

List the certificates which are waiting to get signed and sign them

:: 

	[root@master ~]# puppet cert -l "hostname.domain" (XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX) 
	[root@master ~]# puppet cert sign hostname.domain 
	notice: Signed certificate request for hostname.domain 
	notice: Removing file Puppet::SSL::CertificateRequest hostname.domain at '/var/lib/puppetmaster/ssl/ca/requests/hostname.domain.pem'

If everything went well you should be able to run puppet again on the client

::

	puppet agent --test --noop

and relax again!

Digging the internet I crossed `honglus blog`_ and an issue on `puppetlabs projects`_ which made my day.

.. _honglus blog: http://honglus.blogspot.be/2012/01/force-puppet-agent-to-regenerate.html
.. _puppetlabs projects: http://projects.puppetlabs.com/issues/11854
