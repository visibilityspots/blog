Taskwarrior
###########
:date: 2013-09-30 21:45
:author: Jan
:tags: inuits, tasks, task, taskwarrior, centos, command, line, task-web, mirakel, todo
:slug: taskwarrior
:status: published

I've used a lot's of tools to get a grip on my todo lists for work, for the scouting movement, for technical projects, household, etc. Started by using pen and paper, switched to a little notebook (which I still use for short-term tasks) to start using software to organize them.

I've used evernote, gtasks, tracks, github issues, gitlab issues, redmine tickets, in short plenty passed by only `tracks`_ survived. I still use it for my work related projects, everyday at 8:30AM I get my list of tasks for that day. That way I have some sort of control on my projects.

Nevertheless there was still some sort of missing feature, an integration with the other issue trackers I use like github and redmine for example. I dreamed of one central overview of all my tasks/issues/projects. And some weeks ago I just stumbled into the solution of that dream, `taskwarrior`_ will organize my life from now on.

It's a nifty command line based piece of software with all the features I needed, due dates, projects, tags, customized reports, etc. I completely get enthusiastic when finding out the `bugwarrior`_ module from Ralph Bean which let you to import tasks from many different services like github, redmine & trac.

So I started on this new project by adding a new task to my tracks instance: "Migrate to taskwarrior".

Installation of the `task service`_

.. code:: bash

	# yum install task

By following the `30 sec tutorial`_ you get an idea of the basics, but for a full experience and howto I recommend reading the full `tutorial`_. I created a dedicated user for managing my todo list on my CentOS 6.4 machine.

Configuration of the task service is done in the ~/.taskrc file where you can change the data & log files locations, setting a theme a other configuration parameters.

Installation of `task-web`_, a nice and clear frontend (make sure to use ruby 1.9.3, I had performance issues when using ruby 2.0.0):

.. code:: bash

	# gem install taskwarrior-web thin
	$ task-web -s thin -L &

I added the task-web.user & task-web.passwd parameters to my ~/.taskrc file for basic http authentication, and opted for the thin webserver rather than the default webrick when using the task-web frontend. Once you've stared the service your instance should be accessible on http://your.ip.of.the.server:5678 in your web browser. (make sure to open the port in your servers firewall)

You can choose your own port by adding the option -p XXX in your command (task-web -s thin -p XXX -L &). All the options are listed in the help menu (task-web --help).

Installation of `bugwarrior`_:

As mentioned before the biggest advantage of using taskwarrior to me is the import feature of some several third party services. It's easy to install by using the `pip installer`_:

.. code:: bash

	$ pip install bugwarrior

After that you can configure the ~/.bugwarriorrc file to your needs. After some struggling I got it working with the great help of the developer Ralph Bean.

Example of my ~/.bugwarriorrc file:

::

	[general]
	targets = github, redmine
	log.level = INFO
	log.file = /var/log/tasks/bugwarrior.log
	bitly.api_user = USERNAME
	bitly.api_key = API-KEY
	multiprocessing = True

	[notifications]
	notifications = False

	[github]
	service = github
	username = USERNAME
	default_priority = M
	login = USERNAME
	passw = PASSWORD

	[redmine]
	service = redmine
	url = https://redmine.url
	key = REDMINE-API-KEY
	user_id = NUMERIC-USER-ID
	project_name = NAME-OF-THE-PROJECT-TASK-WILL-GET-ON-IMPORT

Once configured you can run the server and check the log's:

.. code:: bash

	$ bugwarrior-pull
	$ cat /var/log/tasks/bugwarrior.log
	$ task list

Once you initialized the import you can create a cronjob for it:

::

	$ crontab -e
	# Bugwarrior import
	30 5 * * * /usr/bin/bugwarrior-pull

That way every day at 5:30AM the tasks from 3Th party services will be imported.

The only feature I'm still missing is a 2 way synchronization. So I can edit the tasks in taskwarrior too, but that's something for utopia :)

Conky monitoring:

Is a already wrote about before I'm using `conky`_ as a dashboard together with my ratpoison setup. I already wrote a script to fetch my `tracks issues`_. But now I need to fetch my task list from taskwarrior. So I created a custom task report configured in my ~/.taskrc file:

::

	# Custom reports
	report.conky.description=Conky report
	report.conky.columns=project,description.truncated,depends.indicator,priority
	report.conky.labels=Project,Desc,D,P
	report.conky.sort=due+,project+,priority+
	report.conky.filter=status:pending limit:page

Using a ssh connection you can then fetch the output from the command 'task conky' and parse it into a file using a bash script.

Because all my project definitions containing a hyphen I can parse them so I can grep titles and create new lines so I can parse them using the conky syntax.


.. code ::bash

	#!/bin/bash
	ssh username@taskwarrior.server "task conky | head -7 | tail -4 | sed 's/^*[A-Z]*-[A-Z]*/&\n-/g' | sed -e 's/^- [ \t]*/ - /g' | sed 's/^/ /g' | head -4"

I do still have 2 things I need to investigate time into:

Mail weekly tasks

Using `taskreport`_ but I got some errors after installing using 'pip install taskreport':

::

	$ taskreport
	File "/usr/bin/taskreport", line 51
	      for key in ['userName', 'server', 'port']}
	        ^
	SyntaxError: invalid syntax


Installation of `taskd`_ server (for synchronization with mirakel):

Until today the `mirakel`_ app always crashes when trying to sync after initialized with the created key.

.. code:: bash

	# git clone git://tasktools.org/taskd.git
	# wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
	# rpm -Uvh rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
	# yum install cmake28
	# yum install gnutls-devel
	# yum install libuuid-devel
	# cmake28 .
	# make
	# make install

	# yum install gnutls-utils
	# find and replace gnutls-certtool with certtool
	# cd pki
	# ./generate

	# add_user.sh script

.. _tracks: http://www.visibilityspots.com/tracks.html
.. _taskwarrior: http://taskwarrior.org
.. _bugwarrior: https://github.com/ralphbean/bugwarrior
.. _task service: http://taskwarrior.org/projects/taskwarrior/wiki/Download
.. _30 sec tutorial: http://taskwarrior.org/projects/taskwarrior/wiki/30-second_Tutorial
.. _tutorial: http://taskwarrior.org/projects/taskwarrior/wiki/Tutorial
.. _task-web: http://theunraveler.github.io/taskwarrior-web/
.. _pip installer: http://www.pip-installer.org/en/latest/
.. _conky: http://www.visibilityspots.com/conky-colors.html
.. _tracks issues: https://github.com/visibilityspots/scripts#conky-trackssh
.. _taskreport: http://pypi.python.org/pypi/taskreport/
.. _taskd: http://mirakel.azapps.de/taskwarrior.html
.. _mirakel: http://mirakel.azapps.de
