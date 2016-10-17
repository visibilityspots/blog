#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

# This file is only used if you use `make publish` or
# explicitly specify it as your config file.

import os
import sys
sys.path.append(os.curdir)
from pelicanconf import *

SITEURL = "https://visibilityspots.github.io/blog"
RELATIVE_URLS = True

FEED_ALL_ATOM = 'feeds/all.atom.xml'
FEED_ALL_RSS = 'feeds/all.rss.xml'
CATEGORY_FEED_ATOM = 'feeds/%s.atom.xml'
CATEGORY_FEED_RSS = 'feeds/%s.rss.xml'

DELETE_OUTPUT_DIRECTORY = True

DISQUS_SITENAME = "visibilityspots"
ARTICLE_EXCLUDES = ['drafts']

CUSTOM_FOOTER = '<a href="http://creativecommons.org/licenses/by-nc/2.0/be/deed.nl">License</a> | 2009 - 2016 <a href="https://visibilityspots.github.io/blog">visibilityspots.github.io</a> | Powered by <a href="http://getpelican.com/" target="pelican">Pelican</a> | <a href="https://visibilityspots.github.io/blog/feeds/all.atom.xml" rel="alternate">Atom</a> feed'
