Git server
##########
:date: 2013-11-01 14:00
:author: Jan
:tags: git, server, repo, gitweb, gitalist, centos
:slug: git-server
:status: published
:modified: 2013-11-01

For some of my development projects I'm using git repositories because of the flexibility of it. But the initial beta phase I don't want to keep private until I created something working. Normally I use github.com repositories for them, a good service except you have to pay for private repositories.

So I searched the internet for private alternatives and installed `gitlab`_ on my CentOS 6 machine. It worked fine, but it was a bit of an overkill to manage about 10 repositories for only one user, myself. So I decided to migrate it back to the essence.

The essence as: the command line git server with a nice web interface on top of it to have a quick overview of the changes made in which repositories.

I based my git server setup on the git-scm tutorial after reading the chapter about the `git-server`_. It a clear and detailed explanation of the different steps to configure your own private git server.

Once the server was running and I could create new repositories, clone them and push to them from the outside I looked for a nice web frontend. My first choice was the `git-web`_ interface with `lighttpd`_ as the backend web service. The installation of the `gitweb service`_ could also been found on git-scm.

For the lighttpd configuration I created a virtualhost pointing to the gitweb directory in /var/www/gitweb/.

/etc/lighttpd/vhosts.d/gitweb.conf:

::

	$HTTP["url"] =~ "^/gitweb/" {
        	setenv.add-environment = ( "GITWEB_CONFIG" => "/etc/gitweb.conf" )
	        url.redirect += ( "^/gitweb$" => "/gitweb/" )
	        alias.url += ( "/gitweb/" => "/var/www/gitweb/" )
	        cgi.assign = ( ".cgi" => "" )
	        server.indexfiles = ( "gitweb.cgi" )
	        debug.log-request-header          = "enable"
	}

I used this interface for quite some time, but recently I found out about `gitalist`_, a more modern approach to give and overview of your git repositories.

Gitalist is available as a perl-cpan module and could also been installed as such on a CentOS 6 server:

::

	# cpan -i Gitalist

Until today I didn't got enough time to get it fully up and running, mainly because I already have something working so it's not that high on my priority list :)

Resources:

- `git-scm`_
- `git web-interfaces`_

.. _gitlab: http://www.gitlab.org
.. _git-server: http://git-scm.com/book/en/Git-on-the-Server
.. _git-web: https://git.wiki.kernel.org/index.php/Gitweb
.. _lighttpd: http://www.lighttpd.net/
.. _gitweb service: http://git-scm.com/book/en/Git-on-the-Server-GitWeb
.. _gitalist: http://www.gitalist.com
.. _git-scm: http://git-scm.com/
.. _git web-interfaces: https://git.wiki.kernel.org/index.php/Interfaces,_frontends,_and_tools#Web_Interfaces
