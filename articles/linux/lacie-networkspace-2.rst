SSH acces on Lacie Network Space 2
##################################
:date: 2012-05-28 15:18
:author: Jan
:tags: access, capsule, lacie, Linux, NAS, network, root, space, ssh, update
:slug: lacie-networkspace-2
:status: published

Recently we installed a Lacie Network Space 2 at home. Easy to share documents on the LAN network, having a central place for common media etc. After playing around with it I wanted to see if it's possible to gain access to the underlying operating system of it. On that way I could for example use this access to wake up a pc with wake on LAN.

And guess what, it can be done and thanks to a script of a guy Andreus it's even very easy! I found a `forum post`_ about his work and tested it successfully with the latest firmware version 2.2.8!

After you created the right capsule the best way do update is to force it `manually`_.

When you achieved to get ssh access to the device you can play around with it, by for example installing debian squeeze in a chkroot environment. On the `wiki`_ of nas-central.org you can find more information how to play around with your ssh access.

Have fun with it!

.. _forum post: http://forum.nas-central.org/viewtopic.php?f=240&t=4631
.. _manually: http://lacie.nas-central.org/wiki/Category:2big_Network_2#3._Manual_Force_Update
.. _wiki: http://lacie.nas-central.org/wiki/Category:Network_Space_2
