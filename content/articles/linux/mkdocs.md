Title:       Mkdocs documentation
Author:      Jan
Date: 	     2014-04-20 17:00
Slug:	     mkdocs
Tags:	     documentation, mkdoc, automation, pandoc, markdown, html, linux
Status:	     published
Modified:    2017-05-02

To make our and other lives less painful writing documentation is a good start to decrease the level of frustration when working on a shared project.

It's a common feeling writing documentation isn't something we are all waiting for to do. In an effort to make it easier for all of us an automatically way of deployment can be managed by our good friend jenkins in combination with docker.

The details about this flow is been described on this page. After reading through this documentation section you should be aware of the general deployment idea so you can implement it yourself and start writing documentation without any hassle.

## Mark down

The goal is that you write documentation using mark down in a git repository, that way you can easily write together with others on the same documentation in a structured and versionned manner.

By using mark down we can easily convert those md documents to whatever you want and gives us an easy [syntax](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) to write documentation.

## Mkdocs

Using [mkdocs](http://mkdocs.org) a nice and easy manner has been found to generate a clean static html site based on the md files without much effort.

The installation is quite straight forward using python-pip:

```bash
$ sudo pip install mkdocs
```

Once the installation process ended successfully you should be able to run the mkdocs engine:

```bash
$ mkdocs help
  mkdocs [help|new|build|serve] {options}
```

### Usage

Starting a new project is easy as hell:

```bash
$ mkdocs new PROJECT-NAME
Creating project directory: PROJECT-NAME
Writing config file: PROJECT-NAME/mkdocs.yml
Writing initial docs: PROJECT-NAME/docs/index.md
```

the mkdocs structure is automatically generated as you can see in a brand new PROJECT-NAME directory:

```bash
$ ls PROJECT-NAME
docs  mkdocs.yml
```

As you could see the repository exists of a docs directory containing the md files with the actual content and a mkdocs.yml file which is used to generate the sites index and menus

#### local preview

The first thing you could do is to build a local preview of the html structure so you have a real time preview of your modifications:

```bash
$ cd PROJECT-NAME
$ mkdocs serve
Running at: http://127.0.0.1:8000/
Live reload enabled.
Hold ctrl+c to quit.
```

When the mkdocs engine started successfully you could surf through your browser to [localhost:8000](http://localhost:8000) and start watching the preview of your documentation on your local machine.

You should see a site/ directory has been generated containing the static html structure based on the docs/ md files.

After editing the md files and saving your modifications they should appear immediately on your local preview when the mkdocs server command is running.

#### mkdocs.yaml

As mentioned a mkdocs.yml file manages the index and menus of the site:

```yaml
site_name: My Docs
pages:
        - [index.md, Home]
#theme: readthedocs
```

#### images

Using images is quite easy, add your jpg, png or whatever files into the docs/img/ directory and reference to them in your md file as follow:

```bash
![reference name](img/imagefile.png)
```

### Migrate existing documentation

Using [pandoc](http://johnmacfarlane.net/pandoc/) we could convert the majority of source files to markdown:

```bash
$ pandoc source.txt -f textile -t markdown -o output.md
```

Be aware you should review the generated output cause the human intellect still cannot be fully replaced by bits and bytes..

## Automation

Once you've written the documentation in markdown, checked locally the layout and ran through a spell checker you could push them to git repository.

A jenkins build flow could be triggered using a [post-receive](http://git-scm.com/book/en/Customizing-Git-Git-Hooks) hooks.

This flow on his turn will orchestrates some jobs:

* build ( "package-doc" )
* build ( "repository" )
* build ( "deploy-package",  packagename: "infra-doc", node: "webserver.domain.org")

### Package-doc

This job will use the git repository as a source to generate the html site/ directory by the mkdocs build command.

(tip: create a .gitignore file in the root of your git repo with *.~ *.swp and site/ so you don't upload swap files or you local generated site/ directory)

The nifty tool [fpm](https://github.com/jordansissel/fpm) is used to generate an rpm package of that freshly created site/ directory to be deployed on hosting.

```bash
 if [ -f *.rpm ]
 then
     rm *.rpm
 fi

 if [ -d "site/" ]
 then
     rm site/ -rf
 fi

 mkdocs build
 cd site/

 RELEASE=`git rev-list --all | wc -l`

 fpm -s dir -t rpm \
   --name "doc" \
   --version "1.0" \
   --iteration "${RELEASE}" \
   --architecture noarch \
   --prefix /var/www/ \
   --rpm-user apache \
   --rpm-group apache \
   --description 'The html files for documentation' \
   --maintainer 'Jenkins' \
   --epoch '1' \
   .

 mv *.rpm ../
 cd ..

 rpm -qlp *.rpm

```

A brand new shiny rpm package artifact then could be archived so the next step in the flow could use it.

### Repository

The rpm artifact of the package-doc job could then be used to deploy on your favorite repository service, from [createrepo](http://createrepo.baseurl.org/), [pulp](http://pulpproject.org), [yum-repo-server](https://github.com/immobilienscout24/yum-repo-server), [prm](https://github.com/dnbert/prm) to [packagecloud](http://packagecloud.io) so the next job can be triggered to install/update the package on your webserver

### Deploy-package

Next you could configure a jenkins job which for examples logs in through ssh and installs the package you've pushed to your repository.

### Configuration management

Instead of the deployment-package job you could also use a configuration management tool which does the installation/upgrade for you ;)

## Docker

Instead of installing the tools on your local machine or your build server you could also opt for docker, there are a lot of preconfigured docker containers available on the internet or you could start making your own docker file relying on for example a centos official docker container and only mount your markdown documents into the container. That way you have more control over the environment and releases independent of the host system both by the ones who are writing the documentation as your build system..

## Useful links
* [Adam-p](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)
* [Basics](https://help.github.com/articles/markdown-basics)
* [mkdocs](http://mkdocs.org)
* [pandoc](http://johnmacfarlane.net/pandoc/)
* [ispell](http://www.gnu.org/software/ispell/ispell.html)
