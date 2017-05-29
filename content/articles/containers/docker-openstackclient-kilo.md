Title:       Docker openstackclient-kilo container
Author:      Jan
Date: 	     2017-05-29 21:00
Slug:	     docker-openstackclient-kilo
Tags: 	     docker, hub, automated, github, container, openstack, openstackclient, tools, source, at, run, rdo, kilo
Status:	     published

Updated:     2017-05-29 21:00

A couple of years ago I deployed an openstack cluster based on [RDO](https://www.rdoproject.org/). Back in the days we implemented the [kilo](https://www.openstack.org/software/kilo/) release. Until today we didn't updated yet due to various reasons being no need for the new features, no resources, no time no.. Upgrading would be a better option but we'll have to live with it and since it's running rather well so far we are quite happy with it.

To manage that cloud I use the clients I installed on my local machine, from nova to cinder they all have different packages available for many different platforms. Only a couple of weeks ago I noticed the new shiny versions shipping with [Archlinux](https://www.archlinux.org/) aren't working anymore with our setup.

So I looked for alternatives, in the short term I logged in on one of the compute nodes or our [jenkins](https://jenkins.io/) machine to perform the actions I needed to do. But that's bad practice. So I went a bit further and decided to create a docker container for this. Looking on the docker hub there are already some containers available but they don't specify a specific version.

Also this seemed to me like a great exercise to experience the different stages how a docker container could be built up completely by myself. So I went for it and created a [github repository](https://github.com/visibilityspots/dockerfile-openstackclient-kilo) to share my work with the world.

## docker build

The whole setup relies on one [Dockerfile](https://github.com/visibilityspots/dockerfile-openstackclient-kilo/blob/master/Dockerfile). Since I rely on centos in almost every server environment I'm working on I decided to use the centos:7 [official](https://hub.docker.com/_/centos/) docker image.

After some try and error I came to this setup:

```
FROM centos:7
RUN set -x \
	&& yum upgrade -y \
        && yum install -y bash-completion \
	&& yum install -y https://repos.fedorapeople.org/repos/openstack/EOL/openstack-kilo/rdo-release-kilo-2.noarch.rpm \
	&& yum install -y python-novaclient \
	&& yum install -y python-ceilometerclient \
	&& yum install -y python-cinderclient \
	&& yum install -y python-glanceclient \
	&& yum install -y python-heatclient \
	&& yum install -y python-ironicclient \
	&& yum install -y python-keystoneclient \
	&& yum install -y python-manilaclient \
	&& yum install -y python-novaclient \
	&& yum install -y python-openstackclient \
	&& yum install -y python-saharaclient \
	&& yum install -y python-troveclient \
	&& yum install -y python-zaqarclient \
	&& yum clean all \
	&& useradd client

USER client

ENTRYPOINT ["bash", "--rcfile", "/home/client/.keystonerc"]
```

as you could see I opted to install every package using a separate yum install command. That way when a package can't be installed the others aren't infected. Also a yum clean all is performed to cleanup a bit the filesystem to keep the image size a bit under control. By adding a 'client' user I could prevent doing everything as root user which isn't really necessary in our case.

To use the openstack clients, openstack provides a keystonerc file you'll have to source before you could connect through the different API endpoints. I went for the ENTRYPOINT solution which will source a file which can be mounted at run time of the docker container afterwards.

I have to credit my colleague [roidelapluie](https://roidelapluie.be/) here since he guided me to this Dockerfile. To be honest about every option :), but hey I learned a lot about the docker world this way!

So right now everyone should be able to build this container himself by checking out the repository and run the docker build command:

```
$ git clone git@github.com:visibilityspots/dockerfile-openstackclient-kilo.git
$ docker build -t openstackclient-kilo .
```

If everything went well the new created docker image should be available on your machine:

```
$ docker images
REPOSITORY                                          TAG                 IMAGE ID            CREATED              SIZE
openstackclient-kilo                                latest              e89297f75fa8        About a minute ago   331MB
```

## docker run

So you could now use the image to spin up an openstack kilo client container:

```
$ docker run --name openstack-client --rm -ti visibilityspots/openstackclient-kilo
bash-4.2$
```

As already described before the docker container will automatically source a keystonerc file at the /home/client/.keystonerc path. So you could mount a file from your local machine into the docker container at runtime:

```
$ docker run --name openstack-client --rm -ti -v $(pwd)/keystonerc_admin:/home/client/.keystonerc visibilityspots/openstackclient-kilo
[client@a1c38f7635e3 /(keystone_admin)]$ openstack hypervisor list
+----+---------------------+
| ID | Hypervisor Hostname |
+----+---------------------+
|  1 | node-01             |
|  3 | node-02             |
|  4 | node-03             |
+----+---------------------+
```

## dgoss (testing)

Some weeks ago I discovered the docker image testing tool [dgoss](https://github.com/aelsabbahy/goss/tree/master/extras/dgoss) which is comparable with [serverspec](http://serverspec.org/) to write tests in an easy yaml format to be performed against your docker image.

So I decided to give it a try and wrote a [goss.yaml](https://github.com/visibilityspots/dockerfile-openstackclient-kilo/blob/master/goss.yaml) file;

```
package:
  rdo-release-kilo-2:
    installed: true
  python-novaclient:
    installed: true
  python-ceilometerclient:
    installed: true
  python-cinderclient:
    installed: true
  python-glanceclient:
    installed: true
  python-heatclient:
    installed: true
  python-ironicclient:
    installed: true
  python-keystoneclient:
    installed: true
  python-manilaclient:
    installed: true
  python-novaclient:
    installed: true
  python-openstackclient:
    installed: true
  python-saharaclient:
    installed: true
  python-troveclient:
    installed: true
  python-zaqarclient:
    installed: true

file:
  /home/client/:
    exists: true

command:
  openstack --version:
    exit-status: 0
```

which will check if all packages are installed correctly and if the commands are working as they should;

```
$ dgoss run --name openstack-client --rm -ti -v $(pwd)/keystonerc_admin:/home/client/.keystonerc visibilityspots/openstackclient-kilo
INFO: Starting docker container
INFO: Container ID: 539f6896
INFO: Sleeping for 0.2
INFO: Running Tests
File: /home/client/.keystonerc: exists: matches expectation: [true]
Package: python-cinderclient: installed: matches expectation: [true]
Package: python-ironicclient: installed: matches expectation: [true]
Package: python-manilaclient: installed: matches expectation: [true]
Package: rdo-release-kilo-2: installed: matches expectation: [true]
Package: python-novaclient: installed: matches expectation: [true]
Package: python-saharaclient: installed: matches expectation: [true]
Package: python-zaqarclient: installed: matches expectation: [true]
Package: python-glanceclient: installed: matches expectation: [true]
Package: python-troveclient: installed: matches expectation: [true]
Package: python-heatclient: installed: matches expectation: [true]
Package: python-keystoneclient: installed: matches expectation: [true]
Package: python-ceilometerclient: installed: matches expectation: [true]
Package: python-openstackclient: installed: matches expectation: [true]
Command: openstack --version: exit-status: matches expectation: [0]


Total Duration: 0.786s
Count: 15, Failed: 0, Skipped: 0
INFO: Deleting container
```

## docker hub

So now we have a working container on our local machine, but since sharing is caring I wanted to upload it to the [docker hub](https://hub.docker.com/). They have a feature to build your docker container based on a github repository. They also have documented the whole setup of [automated](https://docs.docker.com/docker-hub/builds/) builds pretty good.

So for every git push a new docker image will be released on the docker hub. But they don't test the image before releasing it. 

## travis

So I looked around and found out this can be achieved by [travis](https://travis-ci.org/). I started writing a [travis.yml](https://github.com/visibilityspots/dockerfile-openstackclient-kilo/blob/master/.travis.yml) file which will perform following steps;

```
sudo: required
services:
- docker
before_install:
- curl -L https://goss.rocks/install | sudo sh
- docker build -t visibilityspots/openstackclient-kilo .
script:
- dgoss run --name openstack-client -ti visibilityspots/openstackclient-kilo
after_success:
- if [ "$TRAVIS_BRANCH" == "master" ]; then docker login -u=visibilityspots -p="$DOCKER_PASSWORD";
  docker push visibilityspots/openstackclient-kilo; fi
env:
  global:
    secure: QA24IWGelQ6nd3Xuwzif8L+2AeWC6M8V1jkZNJzJxaBLcxpucWcjkmowzaWGPmVfKeFAgfPsgVPfy8gK03JfY3J4H2AcCa8TWhVOoLvvY6ytFLobCWtRI8nIZoYeV8/BNlKzguoE4OEfrloJUU52tQ/NDWVleH5KCBCj3H93eE52USwZ4JUyoZtngd+Zqma0GUomMvOZ0mg2e87UOYQNnCZehh5okAIU34sKGTGwEwWeqxA9xUvBd3l7pRj+5bfeQ07Fn0n3/tmrzFkOKRfCL2HC63Aq0T0LFjKsYza2QykiI5z4enNVjH8d+/05dCCHaj+/ZqKVQWbMi/RIheXk1XvsxPttBlHC03EXdQBfZmiNUUaxtVQ7f9Df0sRPvIrZsYzbHkeqVSHTNIGZLzY2cizLzIedYLOFGKNRM3WsOokIlsn+f/XciZse0D3YPBPzkRlI6sXMLtduxkZLzC1tRgyZhTl1A1kMbXzj94SJzftQ2NW7g0lbSO38DxsZcy4g/VlTDLmDzHvnlcdiU2KPSXgQcPZXQk/AZuZdl/AaYb9FIhP06GYRVRJfxls5qlxIAxxJsBTyBR4UE7SGq86UtZdTqzr/LjQXQr8SU+KfxvKbOvfBiIrqzMcBaRqQgPfTeKhI+jEhNyAlgnvSQNf8Eg9UgHv6aW51TqyI+RzVqIs=
```

It will install dgoss and build the container locally on the travis infrastructure. Next it will run the dgoss tests based on the goss.yaml file. When those tests are finished it will upload the created and tested docker container to the docker hub.

A detailled log will be provided on [travis](https://travis-ci.org/visibilityspots/dockerfile-openstackclient-kilo)

To get to this travis.yaml file I combined the [official](https://docs.travis-ci.com/user/docker/) travis docker documentation with a [tutorial](https://sebest.github.io/post/using-travis-ci-to-build-docker-images/) I found on the net.

Last but not least I had to disable the automatic build feature of the docker hub repository so only the travis builds will be pushed. That can be done on the "Build Settings" of the docker hub repository.
