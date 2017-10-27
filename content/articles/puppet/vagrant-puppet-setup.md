Title:       Vagrant puppet setup
Author:      Jan
Date: 	     2015-10-10 23:00
Slug:	     vagrant-puppet-setup
Tags: 	     vagrant, rsync, puppetmaster, puppetserver, development, setup
Status:      published
Modified:    2015-10-10

We at [Inuits](https://inuits.eu) are using vagrant for a lot of use cases, neither you are a developer or a sysadmin you for sure will walk into it. Me, myself I do use it merely to automate the many different use cases asked by various projects. It took some time to get myself organized with this pretty nifty piece of software.

In the beginning I used it with the default virtualization provider [virtualbox](https://virtualbox.org) later on I switched to [lxc](https://visibilityspots.org/vagrant-setup.html) containers instead. By using those containers I already gained on performance. Spinning up and down new containers to test if an application is deployed fully automatically got 2 times as fast as when using vm's.

But what I struggled with the most where the many different projects. Each time a new piece of software needed to be automated I copied over the puppet base I used the previous time. Which lead to outdated setups for older projects, many duplicate code over and over again. When updating base modules for both the puppet agent as the puppetmaster previous projects got forgotten..

So I tried to figure out a way I could keep them all up to date with the same code base. We are using [git](https://git.org) for almost all our projects as our versioning platform. So I figured out I could use the features of git to achieve the goals I've setted for my setup. One code base I could update without interrupting the functionality of the different proof of concepts but with the availability of upgrading those in a easy way.

So I started my [vagrant-puppet](https://github.com/visibilityspots/vagrant-puppet.git) project on github. In the master branch a base setup has been configured with a puppetmaster container and a client container. Both are running the latest stable release of puppet 3.x. The puppetmaster is setted up using puppetdb puppetserver or apache/passenger it can be used both with the [centos6](https://atlas.hashicorp.com/visibilityspots/boxes/centos-6.x-puppet-3.x) or [centos7](https://atlas.hashicorp.com/visibilityspots/boxes/centos-7.x-puppet-3.x) containers I crafted using the [lxc-base-boxes](https://github.com/visibilityspots/vagrant-lxc-base-boxes) repository.

# puppet

to automate the different pieces of software we do use puppet, if upstream puppet-modules are available I pull those in through git submodules if not I write my own.

By using the vagrant rsync functionality I could write my module and hiera data in my own preferred environment since they are synced to the running puppetmaster through rsync.

This syncronisation can be achieved in two ways. Manually:

```bash
$ vagrant rsync
```

Or setting up a daemon:

```bash
$ vagrant rsync-auto
```

That way changes you made through your local environment are synced into the puppetmaster container.

# upgrade

## submodules - upstream puppet modules

Every once in a while when a new version of puppet has been released I try to keep my container vagrant boxes up to date. Once those are upgraded I get myself into to master branch and update all the used git submodules with this one liner:

```bash
$ git submodule foreach git pull origin master
```

This way the latest released version of the different used upstream puppet module repositories are fetched into the master branch.

And try to provision my puppetmaster from scratch, depending on the changes been done in the different puppet modules I need to adopt my [hieradata](https://github.com/visibilityspots/vagrant-puppet/tree/master/hieradata). By looking into the hieradata you could see I'm using the puppet roles and profiles principle. With one simple trick in the [site.pp](https://github.com/visibilityspots/vagrant-puppet/blob/master/puppet/environments/production/manifests/site.pp) pointed out by [one](https://twitter.com/PeetersSimon) of my colleagues I created a role based hierarchy in my hieradata. Based on the role fact given in the node hiera data the parameters needed to get the functionality of the role configured are fetched from the role's hieradata.

By doing so the hiera data of a particular role can be easily reused without having to keep them in sync on every node who needs the same role.

I still need to figure out a way I can achieve the same behavior based on profiles data.

This way my master branch keeps staying in sync with the latest releases on the different puppet tools.

## different projects, different branches

But I wanted to go a step further, by getting all my different projects in one place to ease the maintainability of them. So I started tinkering about it. The first idea consisted of having them all in one environment like it would be the case in the real world.

But this has a big disadvantage. It would be a mess in the future when a lot of such proof of concepts are combined in one puppet environment. Also an unneeded level of complexity would been added if you want to show of one particular project to a customer or an interested fellow through the interweb.

It looked for me this was the perfect use case for branches. Every branch created from the master branch already got a working puppetmaster client setup and can easily be upgraded by merging the master branch into it when upgrades are released.

By checking out a branch a subset of different submodules can be loaded after the previous ones are cleaned up:

```bash
$ git checkout feature_branch
$ git clean -d -f -f
$ git submodule update --init --recursive
```

This way the specific puppet modules for a specific projects are loaded with a known working version. When merging from the upgraded master branch the submodules are updated to.

## merging master branch

when the master branch has been upgraded I now can easily merge those updates into the different feature branches:

```bash
$ git checkout feature_branch
$ git clean -d -f -f
$ git merge origin/master
$ git submodule update --init --recursive
$ vagrant up puppetmaster --provider=lxc
$ vagrant up node --provider=lxc
```

By configuring this setup I know have a flexible environment to test deploy and write new puppet code when some piece of software needs to be automated on my local machine with a puppetmaster almost simultaneous to a production one.
