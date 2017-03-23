Tracks
######
:date: 2013-05-16 19:00
:author: Jan
:tags: tracks, gtd, project, management, todo, list
:slug: tracks
:status: published

To get an overview of my todo's I used to list them in google tasks. Back in time I was convinced it would nicely integrate with all tools software and distributions I would use. After some month's I figured out it wouldn't.

So I searched on the web for software which would take that task over from google. I used to play with several tools, from `trac`_, to `chiliproject`_ to `redmine`_.
All those tools worked very nice but were some overkill to only manages todo lists.

In the meantime I installed `gitlabhq`_, tried to abuse the issues there to manage my todo's. But that went into chaos when managing repo's for household tasks etc. When creating that repo I figured out it wasn't logical neither.

So I tumbled into a rails application. `Tracks`_, and hell I like it a lot. It's easy, it can be viewed with `android`_ devices, it mails every week an overview of upcoming tasks for that week and I stripped it out in my `conky`_ setup.

Today I have 2 instances running one on my personal server and one for my tasks at the customer. Depending on location conky shows me the right tasks.

The setup is rather easy, it's all `explained`_ clear on their website. I opted for a sqlite3 database and running `thin`_ to host it.

Nevertheless I still suffer 2 major issues, the `first one`_ is related to the android app. Seems like it shows also closed tasks as being open.

The 2nd one is the frustration of integration github issues. Until today I didn't find a tool which is able to synchronizes all your github issues into whatever application. The only tool I found was `ghi`_ which is just a command line overview of your github tasks.

So please if you found a solution for that don't hesitate to contact me about it! You could make my day!

.. _trac: http://trac.edgewall.org/
.. _chiliproject: https://www.chiliproject.org/
.. _redmine: http://www.redmine.org/
.. _gitlabhq: http://gitlab.org/
.. _Tracks: http://getontracks.org
.. _android: http://xvx.ca/code/tracks-android/
.. _conky: http://conky.sourceforge.net/
.. _explained: https://github.com/TracksApp/tracks/blob/v2.2.2/doc/installation.textile
.. _thin: http://code.macournoyer.com/thin/
.. _first one: https://github.com/adamwg/tracks-android/issues/20
.. _ghi: https://github.com/stephencelis/ghi

