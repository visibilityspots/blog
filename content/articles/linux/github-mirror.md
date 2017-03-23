Title:       Github mirroring
Author:      Jan
Date: 	     2014-10-27 22:00
Slug:	     github-mirroring
Tags: 	     github, mirror, pull, request, git, merge
Status:      published

As an enthusiastic open-source addict I use [github](http://github.com) on a regularly base to share my knowledge with the world, to explore new software tools, to enhance software with new features, to fix bugs, to collaborate with others, and above all to live the open source way!

But I also have to admit that their are some disadvantages too, from time to time the availability, well lacks availability.., you have to pay for private repositories used for testing purposes and github enterprise can't be used publically anymore..

# Self-hosted git

Using your own git instance makes your software less accessible, since like the majority of the open-source software is available through github. But on the other hand, you can use as many private repositories as you want, you can protect your git server from the interweb by running it on your private network, you have control over the availability yourself, ...

You can set up your own [git](http://git-scm.com/book/en/v1/Git-on-the-Server) server quite easy, together with some [frontend](https://git.wiki.kernel.org/index.php/Interfaces,_frontends,_and_tools#GitJungle) it's all under [your own](http://www.visibilityspots.com/git-server.html) control.

Their are some all in one systems available too, like [redmine](http://redmine.org), [gitlab](http://gitlab.com), [chilliproject](http://chilliproject.org) and many others which combines the git repo functionality with some user management system in combination with or without project management and such.

# Mirroring

So I looked for some setup where I could benefit from the github.com awareness and its features as well as the advantages of having your own git instance running.

After digging around I [found](https://help.github.com/articles/duplicating-a-repository/) a mirroring solution which can be automated through for example a [jenkins](http://jenkinsci.org) instance.

```bash
	$ git clone --mirror git@private.gitinstance.org:localOrganisation/localRepo.git mirroring
	$ cd mirroring
	$ git remote set-url --push origin git@github.com:remoteOrg/remoteRepo.git
	$ git fetch -p origin
	$ git push --mirror
```

Setting up a mirror automated or not isn't really the biggest issue to solve. One of the things I was wondering about where the upstream pull requests.

# Merge upstream pull requests

I wanted to have a way to pull those upstream pull requests into my private git repository. And get them synced afterwards with upstream. That way I could benefit of both github.com and a one.

And yes I found a way described by [wincent](https://wincent.com/wiki/Setting_up_backup_(mirror)_repositories_on_GitHub#comment_10143), to do so you have to go through following steps.

First of all go to the directory where your local git repository is located at.

Next up is to add a remote to your private git repo based on the user's upstream repo who made the pull request and fetch his repo into a local branch named to the user for example.

```bash
	$ cd localRepo
	$ git remote add USER git@github.com:USER/REPONAME.git
	$ git fetch USER
```

Once that's done you point your local repo to the master branch of the users branch you just fetched and test if the code is suiting your taste and everything is still up and running.

```bash
	$ git checkout USER/master
```

When you are satisfied the code matches your standards and everything still works fine you can merge the pull request.

```bash
	$ git checkout master
	$ git merge USER/master
	$ git push origin master
```

Once you merged the pull request successfully and you mirrored your local repo to your upstream one, you should see that the upstream pull request also has been automatically closed by your commit.

To keep your repos clean you should remove the freshly fetched branch from upstream out of your local repository

```bash
	$ git remote rm USER
```

# Owner

This whole article only works on git repositories owned by yourself or a git organization you are member of. What I'm still trying to solve is some automated way to keep some upstream github.com repository in sync with a local private git repository through a fork you made on github.com so you could create pull requests yourself to that software.

I am an open-source addict and I really want to make efforts to share features I wrote to existing upstream software by creating pull requests, but time has learned I do forget about creating them. So I should find myself a way how to keep my private local repository in sync with the forked one on github.com by mirroring. And some way I get notified about pieces of software ready to create a pull request.

Once those pull requests are merged by the upstream author they should be synchronized automatically with the fork and the private repo to keep them all in sync.

The reason why I want to automate this process is to not forget about sharing the code with the world cause I lack time, memory and resources to do so..

It's an excuse not worth an excuse and I really should make time for it! #blameingmyself
