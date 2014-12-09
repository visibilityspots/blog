Title:       vagrant-setup
Author:      Jan
Date: 	     2014-12-09 23:00
Slug:	     vagrant-setup
Tags: 	     vagrant, lxc, CentOS, containers, linux, vagrant-lxc, development, devops, operations, centos

In this article I'll try to describe how I use vagrant in my daily tasks as an operations dude as well as I deployed it at one of our customers to help the developers focusing on the coding part rather than the operations part.

# Vagrant

Since the beginning of my career at inuits I'm using [vagrant](https://vagrantup.com) almost everyday. If I got payed every time I spin up a box I could have bought that tesla already some years ago! But unfortunately I'm not :)

For almost 99% of the use cases I use this nifty tool it's related to puppet. Writing modules, testing out some configuration changes on a virtual machine first before pushing the changes to development, fighting with selinux, .. it are all crucial but changes that requires a lot of destroyments of boxes.

# Virtualbox

Like most of us I started using vagrant together with [virtualbox](https://www.virtualbox.org/). In the beginning I had a lot of issues when updating virtualbox, every time it was upgraded my vagrant environment failed to stay up and running.

Once I figured out most of my used vagrant boxes where reliant on the extension pack I never had any issue upgrading virtualbox anymore. The only thing I had to do was to upgrade the [extension pack](https://www.virtualbox.org/wiki/Downloads) too.

It works great, but it's slow as hell when you spin up boxes again and again to test stuff out since it has to boot a whole vm every time. So about a year ago I started looking at some alternatives.

# LXC

Looking around I found out about lxc containers. My interest was triggered at both [linuxcon](linuxcon-edinburgh.html) and [CloudCollab](cloudcollab-amsterdam.html) 2013 where some talks went about containers.

But I struggled configuring the lxc part on my previous fedora machine. It's one of the reasons I switched about a year ago. So I installed [ArchLinux](https://archlinux.org) on my machine and started reading the related [wiki](https://wiki.archlinux.org/index.php/Linux_Containers) pages.

Once I installed all necessary packages I went through the documentation of the [vagrant-lxc](https://github.com/fgrehm/vagrant-lxc) plugin. There I got on a [page](https://github.com/fgrehm/vagrant-lxc/wiki/Usage-on-Arch-Linux-hosts) describing the configuration steps for archlinux.

After following those configuration steps for the networking and DNS part of the lxc functionality I succeeded by creating my very first lxc centos based container:

```bash
  $ sudo lxc-create -t centos -n centos
  Host CPE ID from /etc/os-release:
  This is not a CentOS or Redhat host and release is missing, defaulting to 6 use -R|--release to specify release
  Checking cache download in /var/cache/lxc/centos/x86_64/6/rootfs ...
  Cache found. Updating...
  Loaded plugins: fastestmirror
  Loading mirror speeds from cached hostfile
   * base: be.mirror.eurid.eu
   * extras: be.mirror.eurid.eu
   * updates: be.mirror.eurid.eu
  base                                                          | 3.7 kB     00:00
  extra                                                         | 3.3 kB     00:00
  update                                                        | 3.4 kB     00:00
  Setting up Update Process
  No Packages marked for Update
  Loaded plugins: fastestmirror
  Cleaning repos: base extras updates
  0 package files removed
  Update finished
  Copy /var/cache/lxc/centos/x86_64/6/rootfs to /var/lib/lxc/centos/rootfs ...
  Copying rootfs to /var/lib/lxc/centos/rootfs ...
  sed: can't read /etc/init/tty.conf: No such file or directory
  Storing root password in '/var/lib/lxc/centos/tmp_root_pass'
  Expiring password for user root.
  passwd: Success

  Container rootfs and config have been created.
  Edit the config file to check/enable networking setup.

  The temporary root password is stored in:

          '/var/lib/lxc/centos/tmp_root_pass'


  The root password is set up as expired and will require it to be changed
  at first login, which you should do as soon as possible.  If you lose the
  root password or wish to change it without starting the container, you
  can change it from the host by running the following command (which will
  also reset the expired flag):

          chroot /var/lib/lxc/centos/rootfs passwd

```

```bash
  $ sudo lxc-start -d -n centos
  $ sudo lxc-ls -f
  NAME                                    STATE    IPV4       IPV6  AUTOSTART
  ---------------------------------------------------------------------------
  centos                                  RUNNING  10.0.3.94  -     NO

  $ sudo lxc-console -n centos
  CentOS release 6.5 (Final)
  Kernel 3.17.4-1-ARCH on an x86_64

  centos login:
```

It was a great feeling finally having that box up and running with internet available so I could update the box and install software on it.

# Vagrant-lxc

Next up was to get such an lxc container up and running using the vagrant framework for my local development purposes.

## Manual crafted box

So I first needed to get a centos minimal container with some vagrant tweaks on it. Looking around for documentation about this part I found out a helpful [blog post](http://fabiorehm.com/blog/2013/07/18/crafting-your-own-vagrant-lxc-base-box/).

But every time I tried to get that freshly build custom box up and running it failed. It was frustrating as hell! But when I figured out the logic behind the [vagrant-lxc-base-boxes](https://github.com/fgrehm/vagrant-lxc-base-boxes) project I finally got to a working setup and could close the [issue](https://github.com/fgrehm/vagrant-lxc/issues/328) myself.

So now I could configure a centos minimal lxc container for vagrant usage. But there are a lot of manual steps to perform if I want to keep that box up to date.

## Script crafted box
When founding out about the [vagrant-lxc-base-boxes](https://github.com/fgrehm/vagrant-lxc-base-boxes) project I tried to get up and running a centos box by following the documentation.

But once again it [failed](https://github.com/fgrehm/vagrant-lxc-base-boxes/issues/23) big time. After some digging around I came to the conclusion the environment $PATH's of both archlinux the host and centos the guest are not the same and where the cause of this issue. Together with the missing [ssh server](https://github.com/visibilityspots/vagrant-lxc-base-boxes/commit/4274f0cdf593c26d92e438dd2b36a42f367691d7) package I got the script working.

So I got a step further, I now could create a centos lxc vagrant box pretty easy myself.

## Script crafted box with puppet preinstalled

Since I develop on puppet a lot, that minimal box needed at least the puppet software itself. The code of vagrant-lxc-base-boxes could do that but only for Debian based guests. So I [refactored](https://github.com/visibilityspots/vagrant-lxc-base-boxes/commit/6fddcfec720bc9be80fe5620eabff88c27ae4637) that code for the centos boxes too.

And it worked out great! So great I'm sharing the box through [vagrantcloud](https://vagrantcloud.com/visibilityspots/boxes/centos-6.x-puppet-3.x) so everyone can benefit of the usage of vagrant-lxc.

# Vagrant-cloudstack

At the Cloudstack Collaboration Conference 2014 in Budapest I followed this [tutorial](https://github.com/runseb/runseb.github.io/blob/master/ONEPAGE.md#vagrant) of [Sebastien Goasguen](http://sebgoa.blogspot.be/) where I successfully got a vagrant project up and running as a vm through cloudstack.

It felt great to get that vm up and running only through vagrant. It is like heaven, you can actually start coding in a vagrant-lxc box first, and test your code out on a so called real life production server only by using vagrant up!

# Production setup

Since I got some great experiences with vagrant myself for developing puppet-modules the developers at the customer found out vagrant is really helpful tool in the actual developing part of a project. So we started with a tutorial of vagrant together with virtualbox.

In the initial stage of the vagrant implementation we all used some internet provisioned vagrant box. In the never ending process of improving the infrastructure we came to setup where a custom base box is provisioned by the operations team.

This base box is deployed using the same puppet code and therefore the same configuration as a production like server.

## Base box

Every now and then that base box is updated by one of the operations people and placed on an accessible place for the developers.

The developers have configured vagrant together with the [vagrant-box-updater](https://github.com/spil-ruslan/vagrant-box-updater) plugin. That way every time they bring up a vagrant project based on this base box a check will be performed if they are using the latest provisioned base box.

I do know it looks very like the golden images era. But I do believe also both team should have their focus on the right topic. Writing code for developers and managing infrastructure for operations.

Together with a well-thought deployment process (blog post coming soon) this works out really great.

## Virtualbox custom base box

The base box is crafted based on [vStone](https://vagrantcloud.com/search?utf8=%E2%9C%93&sort=&provider=&q=vstone) boxes and provisioned through puppet.

```bash
  $ vagrant init vStone/centos-6.x-puppet.3.x
  $ vagrant up
```

Once the box is up and running some manual tasks needs to be done

```bash
  $ vagrant ssh
  $ sudo -s
  # yum upgrade
  # yum groupinstall "Development Tools" -y
  # setenforce 1
  # vim /etc/sysconfig/selinux
```

Some [tweaks](http://wiki.centos.org/HowTos/Virtualization/VirtualBox/CentOSguest) for the virtualbox guest additions on centos 6.5

```bash
  # cd /usr/src/kernels/<kernel_release>/include/drm/
  # ln -s /usr/include/drm/drm.h drm.h
  # ln -s /usr/include/drm/drm_sarea.h drm_sarea.h
  # ln -s /usr/include/drm/drm_mode.h drm_mode.h
  # ln -s /usr/include/drm/drm_fourcc.h drm_fourcc.h
  # exit
  $ exit
```

Check virtualbox guest additions using the [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest), that way the virtualbox guest additions are updated automatically every time you bring up the box

```bash
  $ vagrant plugin install vagrant-vbguest
  $ vagrant suspend
  $ vagrant up
```

Package the existing box with some default vagrant configuration

```bash
  $ vim '''Vagrantfile.pkg'''

  Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
        config.vm.box_url = "http://path/to/custom.box"
        config.vm.hostname = "CUSTOMHOSTNAME"
        config.box_updater.autoupdate = true
  end
```

Creation of the box

```bash
  $ vagrant package --output custom.box --vagrantfile Vagrantfile.pkg
```

The custom.box is the actual box you need to provision on an accessible place for the development team.

## LXC custom base box

For the lxc part a custom base box can also be created. To get all the processes done automatically I extended the vagrant-lxc-base-boxes project with an [own_box](https://github.com/visibilityspots/vagrant-lxc-base-boxes/commit/92f14dd76e0e3f777b2a95d8643a45bbb0fff75c) feature.

That way you can easily create a vagrantbox from an actively running lxc container you configured for your own needs.

```bash
  $ git clone git@github.com:visibilityspots/vagrant-lxc-base-boxes.git
  $ cd vagrant-lxc-base-boxes
  $ ACTIVE_CONTAINER=lxc-container-name \
  make own_box
```

To get the name of the running lxc-container you can use the lxc-ls command.


# Example project

I abuse the [vagrant-yum-repo-server](https://github.com/visibilityspots/vagrant-yum-repo-server) project to showcase the usage of vagrant in my world. By using puppet, hiera, directory environments all with the vagrant puppet provisioner you actually get up and running a yum-repo-server yourself without big efforts.

As you can imagine that open up gates for developers AND operations cause they are all using the same puppet-tree so you should have control over the configuration of the box in all stages of the project.

# Improvements

Some improvements where I need more time for are

* automating the actual box creation by for example [jenkins](https://jenkins-ci.org)
* auto update the base boxes processed like a development box using the [ansible](ansible-orchestration.html) orchestration flow
* ..
