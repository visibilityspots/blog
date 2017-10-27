Dashing
#######
:date: 2013-10-31 21:30
:author: Jan
:tags: dashing, monitoring, dashboard, overview, screenly, raspberry pi
:slug: dashing
:status: published
:modified: 2013-10-31

Using multiple nice interface dashboards to get an overview of your services is a great thing. But navigating to them all separately could sometimes be rather pain full.

Therefore I looked for some central place to give a broad overview of all of them. During last year many passed through during my search on the internet. The 2 most interesting ones where `team dashboard`_ and `dashing`_.

Team dashboard is a promising one which could gather extremely specific data and give those back in some nice graphics. That way you could create your own very specific dashboard with all graphics and measurements in the same theme/layout on one central page.

But I was looking for something more simpler and that's what I found with `dashing`_. By using some custom jobs and views I gathered data from `icinga`_, `jenkins`_, `foreman`_ & `bacula`_.

.. image:: images/dashing/rowOne.png
        :target: images/dashing/rowOne.png
	:alt: Dashing first row

.. image:: images/dashing/rowTwo.png
        :target: images/dashing/rowTwo.png
	:alt: Dashing second row

As you can see the square's are showing the total amount of checks from the different dashboard services, if there is one check failing the square of the service will change to a red blinking background. If everything is alright (as it should be) the square is green.

To achieve this I have implemented some checks I found on the internet and wrote some myself:

First row

* `icinga-checks`_
* `foreman-overview`_
* `jenkins-jobs`_
* `bacula-state`_

The first three are using the simplemon widget available in the dashing-scripts repo from `roidelaplui`_

Second row

* `web-services`_
* `jenkins-build-progress`_
* `foursquare-checkins`_
* `tomtom`_

For the tomtom check the `api explorer`_ and `lat-lon coordinates`_ which can be a real help to configure this check.

It's also real easy to configure a raspberry pi which you can connect to a screen using hdmi. Therefore I suggest `screenly`_ which can iterate through a list of assets like web pages (your custom dashing screen ;), images and videos.

That way you could afford a cheap and brilliant monitor screen!

Keep an eye on it ;)

.. _team dashboard: http://fdietz.github.io/team_dashboard/
.. _dashing: http://shopify.github.io/dashing/
.. _icinga: http://icinga.org/
.. _jenkins: http://jenkins-ci.org/
.. _foreman: http://theforeman.org
.. _bacula: http://bacula.org/
.. _github: http://github.com
.. _foursquare: http://foursquare.com
.. _icinga-checks: https://github.com/roidelapluie/dashing-scripts/blob/master/jobs/icinga.rb
.. _foreman-overview: https://github.com/roidelapluie/dashing-scripts/blob/master/jobs/foreman.rb
.. _jenkins-jobs: https://github.com/roidelapluie/dashing-scripts/blob/master/jobs/jenkins.rb
.. _roidelaplui: https://github.com/roidelapluie/dashing-scripts/
.. _bacula-state: https://github.com/visibilityspots/dashing-scripts#bacula-weberb
.. _web-services: https://gist.github.com/willjohnson/6313986
.. _jenkins-build-progress: https://gist.github.com/mavimo/6334816
.. _foursquare-checkins: https://github.com/visibilityspots/dashing-scripts/blob/master/foursquare.rb
.. _tomtom: https://gist.github.com/sighmin/5628306
.. _api explorer: http://developer.tomtom.com/io-docs
.. _lat-lon coordinates: http://www.satsig.net/maps/lat-long-finder.htm
.. _screenly: http://www.screenlyapp.com/ose.html
