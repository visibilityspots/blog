Title:       Ansible orchestration
Author:      Jan
Date: 	     2014-10-21 23:00
Slug:	     ansible-orchestration
Modified:    Sat 25 October 2014
Tags: 	     ansible, orchestration, tool, puppet, dynamic, inventory, puppetdb

I do use [puppet](https://docs.puppetlabs.com/#puppetpuppet) as our main configuration management tool. Together with [puppetdb](https://docs.puppetlabs.com/#puppetdbpuppetdblatest) all our services are automatically configured from bottom to top.

And it rocks, getting automated as much as possible it is like easy as hell to get a server up and running. The only feature it lacked in my opinion is orchestration. I do know about [collective](http://puppetlabs.com/mcollective) which is made for this purpose.

Only it's yet again using an agent which fails from time to time and eating resources which can be avoided. It's the same reason I don't use the puppet agent daemon but trigger puppet every time.

# orchestration

We have puppet running every 15 minutes through cron, main reason is to pick up and install the latest software which has been deployed. The other reason puppet runs after installation is to make sure the configuration files were not manually manipulated and making sure necessary services are still running.

Using puppet for making sure services are running and configuration files are not being changed an hourly puppet run would be enough. Thing is for those deployment flows it's merely like polling. And I strongly hate polling jobs, 99% of the time they don't have to do anything. So to me it's just useless, a waste of time, energy and resources.

It meant that developers had to wait in worst case scenario 15 minutes before their changes where deployed on the development environment. Their changes were already processed by jenkins, packages are been made, deployed on the repository only waiting for puppet to install the latest version of them. Nobody complained, but in my opinion it was waaay too long!

By running puppet immediately after the package is been deployed to the repository the right order of installing, configuring and restarting the necessary services can be executed. This will gain time for deployments next to some hourly puppet cron jobs which are running just to be sure no configuration has changed manually and the services are still running.

# ansible

So I started looking at some solution where I could trigger a puppet run on the hosts configured the software through puppet in the right environment as soon as the package is deployed to the proper repository through jenkins.

At first I looked into the ssh jenkins plugin, it works but has one big disadvantage. You have to configure ssh credentials for every host in jenkins and therefore you can't use abstract jenkins flows cause you need to configure in each job the specific ssh credentials.

I looked further and came across [ansible](http://www.ansible.com). You don't have to configure a client on every host, neither you have to configure a per server based jenkins configuration to get it working. It was a blessing, the only things you have to do is creating a user, his public ssh key and grant him sudo rights on every server. This can easily be done through puppet!

# static inventory

At first I crawled through our [foreman](http://www.theforeman.org) instance and copied over the nodes into 2 groups, development and production, the puppet environments. I also configured some stuff like ssh port and user. I refused to configure the root pw in some plain text file on the jenkins node. That's not safe at all in my opinion, instead I created an ssh key pair and distributed the public key on all servers.

In my fight to automate as much as possible this wasn't the most efficient way of using the inventory. Every time you removed or added a node you had to reconfigure it yourself manually in the first place. Beside the manual intervention you also have to take note how you are gonna perform that manual action? Manipulating configuration data on the production machine is not done, using a git repository which you package or adding them to puppet, which both sounds wrong. The first because it's overkill the second because it's rather data over configuration.

# dynamic inventory

In my quest I got pointed to a [python](https://github.com/EchoTeam/ansible-plugins) script by a colleague. Unfortunately the script isn't straight forward and the 'maintainers' hides themselves behind their footer:

```
  Notice: The puppetdb inventory plugin is not quite generic for the moment. Use more as an example.
```

Once I found out about the [inventory](http://docs.ansible.com/developing_inventory.html) part of ansible I knew what I was looking for and saw the light by an [article](https://blog.codecentric.de/en/2014/09/use-ansible-remote-executor-puppet-environment/) on cedecentric.de. Their was only one issue, my jenkins host which needs ansible to run isn't my puppetmaster and therefore can't list the signed certificates as used in his script.

But I am using [puppetdb](https://docs.puppetlabs.com/puppetdb/latest/index.html), and puppetdb has a great [API](https://docs.puppetlabs.com/puppetdb/2.2/api/index.html). So I could take advantage of it by using this great API, melting it down into an inventory script and using the json generated output through ansible.

So I started modifying the code example I found on codecentrec and got it working by writing a [puppetdb.sh](https://github.com/visibilityspots/ansible-puppet-inventory) dynamic inventory script. Together with the [puppet-ansible](https://github.com/visibilityspots/puppet-ansible) module it even got automated too!

# still need some attention

I need some time to look which processes it takes to run a command through ansible so I could specify more clear the sudoers file.

Also the environments should be more abstract in my puppetdb.sh script without having to manually adapt the necessary puppetdb query files.

# drinking cocktails

From now on it only takes less than 5 minutes to push your code, get it through jenkins tests into a package on an apt or yum repository got pulled into a repository and deploy it through puppet using ansible on the development servers. All without any manual action, without any cron job all automated, glued the pieces together.

I'll dig deeper into the whole deployment process later on, when I found time between drinking cocktails, looking at my daughter and living the dream.
