Writing customized icinga checks
################################
:date: 2012-09-25 11:16
:author: Jan
:tags: centOS, checks, icinga, monitoring, nrpe, server
:slug: icinga-checks
:status: published
:modified: 2012-09-25

Recently I started to try writing a customized script for the `icinga`_ monitoring tool. I will try to describe the steps I went trough to achieve this in this post. I assume you already have a working icinga setup.
If not you can find documentation about this on \ `http://docs.icinga.org/`_.

First of all you need to script. I created a script which will check if a service is running using the command

::

	# /etc/init.d/service status

to see how to implement this in icinga. The script can be found on my `github`_ repo.

Once you have tested the script you have to make sure it is copied to the scripts directory on the server you want to monitor. Usually this directory can be found in /usr/lib64/nagios/plugins/ on a CentOS 6 machine.
Also make sure your script is executable (chmod +x).

Next we have to configure the NRPE daemon on this remote host. The nrpe configuration file can be found in etc/nagios/nrpe.cfg found using the mlocate software.

::

	# updatedb
	# locate nrpe.cfg.

Here you have to make sure that you point the command to your script location by adding the underlying line and restarting the NRPE service

::

	command[check_NAME]=/usr/lib64/nagios/plugins/check_NAME
	/etc/init.d/nrpe restart

The server side where we have to configure the command and the service itself into the icinga service.

We have to add the command check\_NAME into the file /etc/icinga/objects/commands.cfg

::

	define command {
		command_name check_NAME
		command_line $USER1$/check_NAME
	}

To configure the specified service you have to configure a node with this newly created command for in example /etc/icinga/objects/services/node.cfg

::

	define service {
		service_description DESCRIPTION
		check_command check_nrpe_command!
		check_NAME use generic-service
		notification_period 24x7
		host_name HOSTNAME.OF.SERVER
	}

And restart the icinga service

::

	# /etc/init.d/icinga restart

After a few minutes the check should appear into your icinga front-end. Enjoy scripting your own custom scripts!

.. _icinga: https://www.icinga.org/
.. _`http://docs.icinga.org/`: http://docs.icinga.org/
.. _github: https://github.com/visibilityspots/icinga-scripts/blob/master/check_jenkins
