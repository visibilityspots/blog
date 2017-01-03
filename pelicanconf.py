#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = 'Jan'
USE_FOLDER_AS_CATEGORY = True
SITENAME = 'Visibilityspots'
SITEURL = 'http://localhost:8000'
SITESUBTITLE = 'Linux & Open-Source enthusiast | Scouting | Longboarding'
TIMEZONE = 'Europe/Brussels'
DEFAULT_LANG = 'en'
GITHUB_ACTIVITY_FEED = 'https://github.com/visibilityspots.atom'
GITHUB_ACTIVITY_MAX_ENTRIES = 10
#GITHUB_USER = 'visibilityspots'
DISQUS_SITENAME = "visibilityspots"
DEFAULT_METADATA = {
            'status': 'draft',
}
OUTPUT_RETENTION = (".ico")

# Theme
THEME = "pelican-themes/pelican-cait"
ICON = "icon-dashboard"
DISPLAY_CATEGORIES_ON_MENU = False
DEFAULT_PAGINATION = 10
RELATIVE_URLS = True
USE_CUSTOM_MENU = True
CUSTOM_MENUITEMS = (('Blog', ''),
                    ('Profile', 'pages/profile.html'),
                    ('Links', 'pages/links.html'),
                    ('Projects', 'pages/projects.html'),
                    ('Contact', 'pages/contact.html'))

CONTACT_EMAIL = "blog@visibilityspots.com"
CONTACT_TITLE = True
CONTACTS = (('facebook', 'https://www.facebook.com/visibilityspots'),
            ('twitter', 'https://twitter.com/visibilityspots'),
            ('github', 'http://github.com/visibilityspots'),
            ('google-plus', 'https://plus.google.com/107637975925661895622/about'),
	    ('map-marker', 'https://foursquare.com/visibilityspots'),
	    ('pinterest', 'http://pinterest.com/visibilityspots/'),
            ('linkedin', 'http://be.linkedin.com/in/jancollijs'),
            ('desktop', 'http://www.slideshare.net/visibilityspots'),
	    ('ok-circle', 'http://osrc.dfm.io/visibilityspots'))

TAG_CLOUD_STEPS = 4
TAG_CLOUD_MAX_ITEMS = 100
CUSTOM_FOOTER = '<a href="http://creativecommons.org/licenses/by-nc/2.0/be/deed.nl">License</a> | 2009 - 2017 <a href="http://localhost:8000">localhost:8000</a> | Powered by <a href="http://getpelican.com/" target="pelican">Pelican</a> | <a href="http://localhost:8000/feeds/all.atom.xml" rel="alternate">Atom</a> feed'

# Documentes, files and images
STATIC_PATHS = ['images','documents','extra/robots.txt','extra/favicon.ico']
EXTRA_PATH_METADATA = {
    'extra/robots.txt': {'path': 'robots.txt'},
    'extra/favicon.ico': {'path': 'favicon.ico'},
}
IGNORE_FILES = ['*README*']

# Plugins
PLUGIN_PATHS = ['pelican-plugins']
PLUGINS = [
  'github_activity',
  'sitemap',
  'tipue_search',
  'feed_summary'
]

SITEMAP = { 'format': 'xml'}

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
FEED_ALL_RSS = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
FEED_USE_SUMMARY = True
SUMMARY_MAX_LENGTH = 100

# Sitemap
DIRECT_TEMPLATES = ('index', 'tags', 'categories', 'archives', 'sitemap', 'search')
SITEMAP_SAVE_AS = 'sitemap.xml'

# Social widget
SOCIAL = (('twitter', 'http://twitter.com/visibilityspots'),
          ('facebook', 'https://www.facebook.com/visibilityspots'),
          ('github-alt', 'http://github.com/visibilityspots'),
	  ('linkedin', 'http://be.linkedin.com/in/jancollijs'))

# Cache
CACHE_CONTENT = True
GZIP_CACHE = True
CHECK_MODIFIED_METHOD = 'mtime'
LOAD_CONTENT_CACHE = True
