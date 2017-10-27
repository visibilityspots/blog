Puppet module mumble-server
###########################
:date: 2012-04-04 15:31
:author: Jan
:tags: centOS, Linux, module, mumble, mumble-server, open-source, puppet
:slug: puppet-mumble
:status: published
:modified: 2012-04-04

`Mumble`_ is an open source, low-latency, high quality voice chat software primarily intended for use while gaming.

`Puppet`_ is a tool designed to manage the configuration of Unix-like and Microsoft Windows systems decoratively.

The `puppet-mumble`_ module installs a mumble server (version 1.2.3) automatically on a CentOS 6.x machine using the puppet software based on `mumble-documentation`_.

The module needs a repository which contains the `mumble-server`_ package. I distribute this package on my own `visibilityspots`_ repository.

Using puppet this will create the necessary mumble user and group and will configure the mumble-server using your desired settings, like username, password, and tcp port the daemon will listen on.

.. _Mumble: http://mumble.sourceforge.net/
.. _Puppet: http://puppetlabs.com/
.. _puppet-mumble: https://github.com/visibilityspots/puppet-mumble
.. _mumble-documentation: http://mumble.sourceforge.net/Install_CentOS5
.. _mumble-server: http://www.visibilityspots.com/repos/repoview/mumble-server.html
.. _visibilityspots: http://www.visibilityspots.com/repos/repoview/
