Irssi bitlbee channel
#####################
:date: 2013-05-10 13:30
:author: Jan
:tags: irssi, bitlbee, channel, chat, groupchat, jabber, xmpp
:slug: irssi-bitlbee-channel
:status: published

Every time I want to join a channel on a jabber account using bitlbee I'm a bit confused and have to search the whole inter-webs before actually finding out howto configure my chat setup to do so.

My online search points me out to the `bitlbee wiki`_. Nevertheless those commands never got to the point to have it actually working. After many attempts a colleague pointed me to the right solution.

To never forget it anymore and sharing the working setup with the world I summarize it in this blog post.

In your bitlbee control channel **&bitlbee** :

::

	chat add [account id] room@conference.jabber.link #room
	/j #room

As you can see in the chat add command the ending #room was missing in the online documentation.

Hope to tackle many frustrations by this one :)

.. _bitlbee wiki: http://wiki.bitlbee.org/JabberGroupchats

