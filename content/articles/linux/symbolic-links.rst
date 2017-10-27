Symbolic linux links
####################
:date: 2010-02-10 23:14
:author: Jan
:tags: /usr/bin/, link, linux, symbolic, terminal
:slug: symbolic-links
:status: published
:date: 2010-02-10

It's rather simple, but I used to look for it a while when writing my first bash/python scripts. Wanted to typing in one command so I would need to type in every time the whole path to my newly written script.

That way routine tasks could be called much faster and easier. This can be done by creating a symlink to your /usr/bin directory:
::

	 ln -s /path/to/your/script /usr/bin/nameOfTheOverallCommmandYouWantToUseForYourScript
