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
ONEPUBLISHCONF=$(BASEDIR)/one_publishconf.py

SSH_HOST=ssh.visibilityspots.com
SSH_PORT=22
SSH_USER=visibilityspots.com
SSH_TARGET_DIR=/www

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
	@echo '   make serve [PORT=8000]           serve site at http://localhost:8000'
	@echo '   make devserver [PORT=8000]       start/restart develop_server.sh    '
	@echo '   make stopserver                  stop local server                  '
	@echo '   make one.com                     upload to one.com		      '
	@echo '   make aws	                   upload to aws instances            '
	@echo '   make github                      upload the web site via gh-pages   '
	@echo '                                                                       '
	@echo 'Set the DEBUG variable to 1 to enable debugging, e.g. make DEBUG=1 html'
	@echo '                                                                       '

html:
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

clean:
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)

regenerate:
	$(PELICAN) -r $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

serve:
ifdef PORT
	cd $(OUTPUTDIR) && $(PY) -m pelican.server $(PORT)
else
	cd $(OUTPUTDIR) && $(PY) -m pelican.server
endif

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

github_publish:
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(GITHUBPUBLISHCONF) $(PELICANOPTS)

one_publish:
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(ONEPUBLISHCONF) $(PELICANOPTS)

aws_publish:
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(AWSPUBLISHCONF) $(PELICANOPTS)

one.com: one_publish
	rsync -e "ssh -p $(SSH_PORT)" -P -rvz $(OUTPUTDIR)/ $(SSH_USER)@$(SSH_HOST):$(SSH_TARGET_DIR) --cvs-exclude

aws: aws_publish
	cd $(OUTPUTDIR) && s3cmd sync $(OUTPUTDIR)/ s3://$(S3_BUCKET) --exclude 'log/*' --exclude 'status.html' --acl-public --delete-removed --guess-mime-type

github: github_publish
	cd $(INPUTDIR) && ghp-import -m 'Updating repository to real world blog' -n $(OUTPUTDIR) && git push origin gh-pages

.PHONY: html help clean regenerate serve devserver publish one.com aws github
