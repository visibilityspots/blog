Hubot, the github chat automated bot
####################################
:date: 2013-06-03 19:00
:author: Jan
:tags: hubot, irc, xmpp, chat, bot, github, scripts
:slug: hubot

Some weeks ago I was asked by a customer to implement a bot on an IRC channel. Did some research about this topic and stumbled on the github `hubot`_.

The installation on a dedicated server running CentOS 6, using the irc adapter isn't hard. By following those steps you can easily start your own bot on a specified IRC channel.

You need some pre installed packages:

::	
	
	# yum install openssl openssl-devel openssl-static crypto-utils expat expat-devel gcc-c++ git

After installed those pre requirements nodejs is the next service we need. You can install the newest version using rpm packages you can find on the internet. For example on my `repo`_ or building it from source:

::
	
	$ wget http://nodejs.org/dist/v0.8.17/node-v0.8.17.tar.gz
	$ tar xf node-v0.8.17.tar.gz -C /usr/local/src && cd /usr/local/src/node-v0.8.17
	$ ./configure && make && make install

As you can see in the output, npm is installed into the '/usr/local/bin/' directory. To get this working in bash you could add this directory into your $PATH environment

::

	$ PATH=$PATH:/usr/local/bin/

So now we can use npm to install hubot and coffee-script:

::

	$ npm install -g hubot coffee-script

You could now create your very own dedicated hubot by declaring the necessary files into your preferred path:

::
	
	$ hubot -c /opt/hubot/

That way the core hubot you can use is installed in its own directory. We now have to install and configure the `irc-adapter`_. Therefore you need to adapt the package.json file in your newly created hubot folder (/opt/hubot/) by inserting the hubot-irc dependency:

::	
	
	"dependencies": {
	  "hubot-irc": ">= 0.0.1",
	  "hubot": ">= 2.0.0",
	  ...
	}

Once that's done you can install the dependencies by using npm:

::	
	
	$ npm install

Last thing you have to do is configure the needed irc parameters. This can be done by exporting the environment parameters. I decided to use a file to accomplish this. In the /opt/hubot/ directory I created a hubot.env file containing the necessary parameters:

::	

	# IRC adapter parameters
	export HUBOT_IRC_NICK="NAMEOFYOURBOT"
	export HUBOT_IRC_ROOMS="#CHANNELONIRC"
	export HUBOT_IRC_SERVER="irc.freenode.net"
	export HUBOT_IRC_DEBUG="false"
	export HUBOT_IRC_UNFLOOD="false"
	export HUBOT_IRC_SERVER_FAKE_SSL"false"
	export HUBOT_IRC_USESSL"false"

Most of those params are quite obvious, the unflood param configured to false prevented the hubot to crash when someone asked hubot: help ;)

After I tested this standard setup out I started to write a `puppet-hubot`_ module to automate those steps and configuration on a CentOS machine. Using a the `puppet-nodejs`_ module which installs the `nodejs`_ rpm I packaged on my visibilityspots `repo`_ the installation become easy peasy.

By using this puppet setup a hubot `init`_ script is automatically deployed so a hubot init service can be used for starting, stopping, restarting and getting the status of the hubot service on your dedicated machine.

As you can see in the init script I use a hubot user to run the hubot. That way it's a bit more secure to run the hubot service on your server. 

A 2nd script which is deployed using the puppet-hubot module is the `hubot-plugin.sh`_ script. By using this script you can automatically install a script from the hubot scripts `catalog`_. If the author of the script uses the standard documentation rules the scripts will declare it self in your hubot-scripts.json file, declaring it's dependencies in the package.json file, if there are adding it's needed configuration parameters in plugins.env and restarting the hubot service.

If you notice a script which hasn't been documented the standard way, you can easily use pull requests, the author of the github hubot-scripts repository really takes it serious and merge those requests on a regular base. 

Last but not least I also created a hubot instance using the `xmpp-adapter`_. After some desperate debugging and failing I figured out that for the irc adapter it doesn't matter which nodejs version you installed. For the xmpp adapter on the other hand it only worked by installing nodejs v0.8.17 build from the sources and by never ever use npm update but npm install instead to install the npm dependencies.

It saves you a lot of time if you take that tip in memory :)

Enjoy using your hubot

.. _hubot: http://github.hubot.com
.. _puppet-hubot: https://github.com/visibilityspots/puppet-hubot
.. _irc-adapter: 'https://github.com/github/hubot/wiki/Adapter:-IRC
.. _puppet-nodejs: https://github.com/visibilityspots/puppet-nodejs
.. _nodejs: http://nodejs.org
.. _repo: http://repository.visibilityspots.com/repoview
.. _xmpp-adapter: https://github.com/markstory/hubot-xmpp
.. _init: https://github.com/visibilityspots/scripts/blob/master/hubot
.. _hubot-plugin.sh: https://github.com/visibilityspots/scripts/blob/master/hubot-plugin.sh
.. _catalog: http://hubot-script-catalog.herokuapp.com/
