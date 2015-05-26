Permissions website
####################
:date: 2010-02-09 18:08
:author: Jan
:tags: hosting, linux, online, permissions, shell, web, security
:slug: web-permissions
:status: published

The most recommended permissions for files and directories on the web are 0755 and 0644. If you have shell access to your webserver you can set those permissions using those commands:
::

	find -type d -print0 | xargs -0 chmod 755
	find -type f -print0 | xargs -0 chmod 644
