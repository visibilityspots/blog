PY?=python3
PELICAN?=pelican
PELICANOPTS=

BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/content
OUTPUTDIR=$(BASEDIR)/output

CONFFILE=$(BASEDIR)/pelicanconf.py

PUBLISHCONF=$(BASEDIR)/publishconf.py
GITHUBPUBLISHCONF=$(BASEDIR)/github_publishconf.py
AWSPUBLISHCONF=$(BASEDIR)/aws_publishconf.py

S3_BUCKET=visibilityspots.org

GITHUB_PAGES_BRANCH=master

DEBUG ?= 0
ifeq ($(DEBUG), 1)
	PELICANOPTS += -D
endif

help:
	@echo 'Makefile for a pelican Web site                                        '
	@echo '                                                                       '
	@echo 'Usage:                                                                 '
	@echo '   make html                        (re)generate the web site          '
	@echo '   make clean                       remove the generated files         '
	@echo '   make regenerate                  regenerate files upon modification '
	@echo '   make publish                     generate using production settings '
	@echo '   make devserver [PORT=8000]       start/restart develop_server.sh    '
	@echo '   make stopserver                  stop local server                  '
	@echo '   make aws-deploy                  upload to aws instances            '
	@echo '   make github-deploy               upload the web site via gh-pages   '
	@echo '                                                                       '
	@echo 'Set the DEBUG variable to 1 to enable debugging, e.g. make DEBUG=1 html'
	@echo '                                                                       '

html:
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

clean:
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)

regenerate:
	$(PELICAN) -r $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

devserver:
ifdef PORT
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)
	$(BASEDIR)/develop_server.sh restart $(PORT)
else
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)
	$(BASEDIR)/develop_server.sh restart
endif

stopserver:
	kill -9 `cat pelican.pid`
	kill -9 `cat srv.pid`
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)
	@echo 'Stopped Pelican and SimpleHTTPServer processes running in background.'

publish:
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(PUBLISHCONF) $(PELICANOPTS)

github-build:
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(GITHUBPUBLISHCONF) $(PELICANOPTS)

aws-build:
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(AWSPUBLISHCONF) $(PELICANOPTS)

aws-deploy: aws-build
	cd $(OUTPUTDIR)
#	s3cmd sync $(OUTPUTDIR)/ s3://$(S3_BUCKET) --exclude 'log/*' --exclude 'cflog/*' --exclude 'status.html' --acl-public --delete-removed --guess-mime-type -v -d
	s3cmd --acl-public --cache-file=md5-list --delete-removed --guess-mime-type --cf-invalidate --stats -v sync $(OUTPUTDIR)/ s3://$(S3_BUCKET)

github-deploy: github-build
	cd $(INPUTDIR) && ghp-import -m 'Updating repository to real world blog' -n $(OUTPUTDIR) && git push origin gh-pages

.PHONY: html help clean regenerate serve devserver publish one.com aws github
