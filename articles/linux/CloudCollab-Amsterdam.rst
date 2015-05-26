CloudCollab Amsterdam #CCCEU13
##############################
:date: 2013-11-23 19:00
:author: Jan
:tags: cloudstack, conference, cloudcollab, Amsterdam, cloud, apache, 2013, #CCCEU13
:slug: cloudcollab-amsterdam
:status: published

Cloudstack, an item I had on my todo list with some lower priority against daily maintenance of our server park. But since attending `David Nalley's`_ talk on LinuxCon I shifted it up some places. Although I expected a real hands on session the talk he gave about a cloudstack environment for development was really intriguing and matched completely with what I had in mind. 

Being fully convinced it fits in my idea of a fully automated development environment which meets to all the needs of developers to start writing code real quickly on machines similar to the production environment.

At that same conference LinuxCon I also attended a talk from `James Bottomley`_ about a container based cloud. I already did some stuff with lxc containers on my local machine hoping I could get it working one day so I could get rid of virtualbox and using containers for my puppet development instead. But I never thought about integrating containers in a cloud instead of the traditional hypervisors.

James gave a really inspiring talk about containers and passed his enthusiasm about it! Nevertheless it's a huge step to migrate from a traditional virtual based setup to a cloud based on containers. A huge challenge, but a challenge I can't wait to start on.

Some weeks after LinuxCon, CloudCollab took place, a chance I took with both hands when being asked to keep those days free. And so I drove to Amsterdam the evening before the event. I learned to read through the whole registration process and not let emotions and enthusiasm take it over so you forget or over read some major things. Thanks at those who fixed that the day before the event.

Hackathon Workshop day
----------------------

I registered early at the `Beurs van Berlage`_ where the conference is held cause I hate waiting queues. The opening talk was quite clear, we cloud/system admins must prevent the end users application developers and such to have frustrating moments where they banging their heads to the table.

With that said the workshops begun, I registered for the one-day cloudstack bootcamp by `shape blue`_. After dealing with the exfat file system a friendly neighbor and changing some setting in the provisioned ova file for the xenserver I managed to go through the whole cycle of setting up domains, groups, accounts, networks, offering templates to finally getting up some vm's running and being able to access through ssh.

To do this we used the GUI, I'm looking forward to use the api they showed at the end of the day which looked far more my kinda usage then the GUI.

After the bootcamp my head was still dizzy but I took the opportunity to attend the `elastic-search user group`_ meeting being held at booking.com. `Ralph Meijer`_ `spoke`_ about Logstach, Kibana and elasticsearch. Where `vulcan`_ popped out for me as being interesting in combination with such a setup.

Conference day one
------------------

After being waked up 5 min early, I started the second day at CloudCollab by attending the Keynote of `John Willis`_ talking about the next frontier for devops. An entertaining talk but also very interesting topic. It seems like the history will repeat but now in networking area.

After the break I attended a talk about Devops, Killing of the Dinosaurs. Where all kind of culture troubles and people are compared to dinosaurs and how they achieved to kill them to get on.

I figured out I forgot my notebook at the keynote, luckily it was still where I left it, but I missed therefore the talks during that time. So I continued writing this post.

Next where the ignite talks, short talks where the slides are automatically flipped each 15 seconds. Unless you cheat and create duplicate slides off course. John Willis can talk like a machine, really really fast but still understandable.

Lunch being served stopped by some boots I started the afternoon by attending a talk about `vagrant-cloudstack`_, which is really cool, finally I could perhaps using vagrant boxes exactly the same as a normal production server for development of puppet-modules without having to kickstart manually some boxes. This cloudstack virus is really getting me.

`The future of sysadmins`_, finally I could attend a talk of our colleague `Kris Buytaert`_. Beside that fact I really was astonished that the way we are working at `Inuits`_ using automated pipelines, vagrant development, jenkins even pulp isn't yet commonly used. I couldn't believe I was like the only knowing some of the answers on Kris's questions. Obviously he would have nailed me when I didn't, but the only one? It's a mixed feeling being proud that we doing all those cool stuff, a bit disappointed not the majority of organizations are taking advantage of it.

After Kris's talk I went to a talk about monitoring a cloudstack environment. It felt like a sales talk for ca technologies own proprietary tool. Bit disappointing that it wasn't what I expected to be after reading the summary on lanyrd about the talk.

So I went for a coffee and bumped into some guys of the University Library of Cambridge at the Pinball machine in the dev room. Cool to see the story of their environment is quite the same as ours at the University Library of Ghent. 

Being at the end of the day I followed a user panel about 4 organizations who implemented cloudstack for their business all with a different approach and goals. The one that popped out for me was `Greenqloud`_ an Icelandic cloud provider running on 100% renewable energy (as everyone in Iceland), but which also does effort in other areas, like their hardware itself and the buildings their datacenters are deployed in.

After dinner we had a great time with the folks of `shape blue`_ and `schuberg philis`_ at the pub. It's really fascinating to see such a dynamic atmosphere.

Conference day two
------------------

The last day of the conference started by checking out the hotel and attending the delayed keynote of `Mark Burgess`_ about Uncertain Cloud Infrastructures. His book `In search of certainity`_ is added to my wish list for the upcoming holiday gifts.

Next talk I joined was about the `Netapp cloudstack plugin`_ which was really interesting, I hope I can get my hands on the beta version of the `VSC for cloudstack`_ software soon so I can start playing around with it on our test lab.

After being disappointed by a vendor talking about a topic which ended up in a sales talk I didn't had big expectations for the talk of `Mike Tutkowski`_ from Solid-fire about Guaranteed storage performance. But man how I was wrong. What a great talk. The guy really knew what he was talking about, explained how the storage area of cloudstack works and how they integrated it with their products. All vendor based sales talks should attend this talk and learn from it. That way more people could be becoming interested in your product only because of the clear and transparent explanation. 

Because I'm looking for some scalable storage solution I attended the talk of `Wido den Hollander`_ about `ceph`_. Wido is a passionate ceph lover who gave a crash course of ceph in 30 minutes. In that little time he really gave a clear overview of how ceph could be used together with cloudstack. Using little pizza box servers with one cpu and four disks you could easily manage your own ceph storage cluster. 

After those 2 storage talks I came to this conclusion for myself that `ceph`_ would be a great challenge if you want to keep control over your own storage soft- and hardware based besides the fact you also have to keep in mind about the physical space. 

Another solution could be a solid-fire solution where you move the responsibility to a vendor. A great advantage of solid-file is that you can start with a small amount of data and grow your storage on a flexible and scalable manner to your own needs by just adding an extra node like the ceph solution and not like other vendors where you need to review the whole license contract.

I decided to attend the storage panel after those 2 talks being convinced that not only the cloud solution is important and changing the traditional ways of Virtualization but also storage is moving over to some more advanced flexible solutions.

Nevertheless I couldn't really hold my focus to the discussions being overwhelmed of the idea of the flexibility of those storage clusters being scalable, reliable and flexible volumes along on or more racks in multiple datacenters. I can only remember the statement of Wido: 'We still have storage problems. They are called NFS and iSCSI' because of my daydreams about storage clusters.

Being already 16hrs and a bit mental overwhelmed I was hesitating to leave already to home or attending the latest slots of talks. I decided to stay being interested about `Tim Mackey`_'s talk on the different hypervisors and how to choose between them to drive your cloud solution. He made a clear comparison between the different options. I hope I can catch his slides soon to share with you.

The closing note ended with a nice video about the conference was a great closing for a conference where I learned so many new technologies, options between the different solutions and inspiring people.

I want to thank hereby the people of `Schuberg philis`_ for the organization!

.. _David Nalley's: https://twitter.com/ke4qqq
.. _James Bottomley: https://twitter.com/jejb_
.. _Beurs van Berlage: http://www.beursvanberlage.nl/
.. _shape blue: http://shapeblue.com/
.. _elastic-search user group: http://www.meetup.com/ElasticSearch-NL/
.. _spoke: http://www.elasticsearch.org/blog/using-elasticsearch-and-logstash-to-serve-billions-of-searchable-events-for-customers/
.. _vulcan: https://github.com/mailgun/vulcan
.. _Ralph Meijer: https://twitter.com/ralphm
.. _John Willis: https://twitter.com/botchagalupe
.. _vagrant-cloudstack: https://github.com/klarna/vagrant-cloudstack
.. _The future of sysadmins: http://www.slideshare.net/KrisBuytaert/the-future-of-sysadmin
.. _Kris Buytaert: https://twitter.com/krisbuytaert
.. _Inuits: http://www.inuits.eu
.. _Greenqloud: http://www.greenqloud.com
.. _schuberg philis: http://www.schubergphilis.com/
.. _Mark Burgess: https://twitter.com/markburgess_osl
.. _In search of certainity: http://www.amazon.com/In-Search-Certainty-Information-Infrastructure-ebook/dp/B00ENEEWYO
.. _Netapp cloudstack plugin: https://github.com/apache/cloudstack/tree/master/plugins/file-systems/netapp
.. _VSC for cloudstack: http://www.netapp.com/us/products/management-software/
.. _Mike Tutkowski: http://www.linkedin.com/pub/mike-tutkowski/6/28/588
.. _Wido den Hollander: https://twitter.com/widodh
.. _ceph: http://www.ceph.com
.. _Tim Mackey: https://twitter.com/XenServerArmy
