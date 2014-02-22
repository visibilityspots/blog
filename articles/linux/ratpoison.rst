Ratpoison window manager
########################
:date: 2013-05-22 19:00
:author: Jan
:tags: ratpoison, window, manager, fedora, desktop
:slug: ratpoison

My first steps in linux where on a ubuntu distribution, when you could order the ISO images on a cd-rom delivered by the post.

I liked it a lot and ever since I only used linux on my home based devices. Following the releases of Ubuntu. Starting at inuits I tried something else and installed CentOS desktop on my laptop. The idea behind this was to gain experience on the CentOS distributions.

Once I figured out that it didn't made sense since a laptop has other purposes then a server. By the time we got new machines I decided to install fedora on it. Nevertheless I don't like the gnome 3 unity layer. It's not that it's bad, But I just don't like it. So I started by installing `mate-desktop`_.

By playing around and looking how other people are configuring and using their local machines a colleague pointed me to `ratpoison`_. Because I could install this window manager nicely next to the existing mate-desktop I gave it a try. Shameful I have to admit that when I first gave it a try I thought I did something wrong on the installation. That installation is not that hard on fedora, since they packaged it in their own repository:
::

	$ sudo yum install ratpoison

Once installed you can logout and try to log in after changed your window manager. For me that first introduction was like I already mentioned a bit shameful. Nothing happened, I only saw a black background and couldn't do anything. It took me some time to figuring out that you had to use a keyboard pre configured strike to get started using the ratpoison functionality. And by default that is CTRL-T.

So if you for example tap in CTRL-T and then SHIFT-V you should see the ratpoison version disclaimer.

Once I figured that out I started to configure the whole environment for my needs. After some try and error I finally became in love with it. My screen movements are a lot faster by moving around screens, windows and applications trough my keyboard without physical moving my hands!

The configuration is done in the ~/.ratpoisonrc file:
::
	
	# Ratpoison configuration
  	startup_message off
	set winname class
  	
	# Desktop 
	set padding 0 0 0 93
	exec conky -c ~/.conky/conkyrc
 	feh --bg-scale ~/path/to/background/picture.png
	exec xscreensaver -nosplash
 
To begin I disable the startup message which only says what your keystroke is. Then I configure my desktop, setting a padding at the bottom of my screen so my `conky`_ setup is displayed smoothly on my screen. Starting the conky daemon, setting a background picture and starting the xscreensaver daemon.
::
	
	 # Startup programs
	exec dropbox start
	exec dropbox2
	
	exec /home/Jan/.scripts/fnotify -s
	exec /home/Jan/.scripts/ratcpi
	exec /home/Jan/.scripts/detectPhone

The second part of my .ratpoisonrc file is the file with my startup scripts. To start my dropbox scripts as explained on a previous `post`_, the `fnotify`_ script to display irssi notifications, `ratcpi`_ for displaying battery notifications and `detectPhone`_ which looks for my phone by bluetooth to decide to lock my laptop yes or no.
::
	
	# Aliasses
	alias showroot exec ratpoison -c $HOME/.rpfdump; ratpoison -c 'select -' -c only
	alias unshowroot exec ratpoison -c "frestore at $HOME/.rpfdump"
	alias showpadding set padding 0 0 0 93
	alias showfullscreen set padding 0 0 0 0
	alias term exec terminator
 
	# Bindings
	unbind n
	unbind c
	unbind s
	unbind Q
 
	## Software bindings
	bind d exec chromium-browser
	bind c exec terminator
	bind C-c exec terminator
	bind l exec xscreensaver-command -lock
	bind C-s exec spotify
	bind s exec synapse
 
	## Move bindings
	bind C-k delete
	bind r restart
	bind n nextscreen
	bind C-n nextscreen
	bind b showroot
	bind B unshowroot
	bind p showpadding
	bind f showfullscreen
	
	bind v hsplit
	bind h vsplit
	bind q only

This last part is about setting my key stroke bindings. Most of them are self explaining, all those keys need a pre hit of CTRL-T before called. 

.. _mate-desktop: http://mate-desktop.org
.. _ratpoison: http://www.nongnu.org/ratpoison/
.. _conky: http://www.visibilityspots.com/conky-colors.html
.. _post: http://www.visibilityspots.com/dropbox.html
.. _fnotify: https://github.com/visibilityspots/scripts#fnotifysh
.. _ratcpi: https://github.com/jbaber/ratpoison_scripts/blob/master/Ratcpi/Ratcpi
.. _detectphone: https://github.com/vlachoudis/DetectPhone
