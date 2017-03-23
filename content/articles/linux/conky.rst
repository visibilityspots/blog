Conky
#####
:date: 2009-12-30 14:18
:author: Jan
:tags: conky, conky-colors, monitor, ubuntu, karmic, linux
:slug: conky
:status: published

To monitor the different resources of my local system I use conky. After you installed the conky software you can start with the configuration of it.
::

	$ apt-get install conky conky-colors

After I adapted the configuration my desktop became like this:

.. image:: images/conky/desktop.png
        :target: images/conky/desktop.png
	:alt: Desktop image

At the left side there is a pane which only monitors my system resources. The config file for it, `conkyrc`_ should be placed in your home directory as a hidden file (naming it .conkyrc).

When you now type in conky in your terminal, you should see appearing the pane on your desktop:

.. image:: images/conky/conky.png
        :target: images/conky/conky.png
	:alt: Left panel

On the right bottom I created an rss feeds pane. In the file `conkyrc2`_ some parameters needs your attention. After you found your rss feeds, you can displays them by this instruction (10 stands for the refresh interval in minutes, 5 for the last 5 items of your feed):

::

	${rss http://jouwfeed 10 item_titles 5}

Once you adopted the file and placed in as a hidden file in your home directory you can start the monitor by:

::

	conky -c ~/.conkyrc2

Using the parameter -d you can force the service to start up as a background daemon process:

::

	conky -c ~/.conkyrc2 -d

.. image:: images/conky/conkyrc2.png
        :target: images/conky/conkyrc2.png
	:alt: Right bottom panel

The last pane, on the right top, I configured with for monitoring my social networks and communication. In the `conkyrc3`_ file you need to adopt the twitter and linkedin feed.

For the twitter rss feed you need 3 params: username, password, and a token. To find your token, surf to and click on the right bottom to get your rss feed. In your browser url address bar you can find the token at the end of the url XXXXXXXX.rss.
::

	${rss http://twitternaam:twitterwachtwoord@twitter.com/statuses/friends_timeline/twittercode.rss 20 item_titles 2}

For the linkedin rss feed, you need to log in on linkedin.com and search for your own rss feed on the homepage. To display pidgin statuses I used the `conkyPidgin`_ module.

After you adopted the last configuration file once again, place it in your homedir, hide it and start it in your terminal:
::

	conky -c ~/.conkyrc2

.. image:: images/conky/conkyrc3.png
        :target: images/conky/conkyrc3.png
	:alt: Right top panel

To automatically start up the conky daemons, you could call a .startConky.sh script with this code:
::

	#!/bin/bash
	sleep 30 && conky -d;
	sleep 40 && conky -c ~/.conkyrc2 -d;
	sleep 50 && conky -c ~/.conkyrc3 -d;

	chmod +x .startConky.sh

Then add this command to menu System - Preferences - Startup Applications:
::

	~/.start_conky.sh

This way you also could monitor your system in a fancy way :)

.. _conkyPidgin: http://ubuntuforums.org/showthread.php?t=969933
.. _conkyrc: http://www.visibilityspots.com/documents/conky/conkyrc
.. _conkyrc2: http://www.visibilityspots.com/documents/conky/conkyrc2
.. _conkyrc3: http://www.visibilityspots.com/documents/conky/conkyrc3
