Title:       Auto deploy webpage using pelican and travis
Author:      Jan
Date: 	     2017-05-21 22:00
Slug:	     pelican-travis
Tags: 	     pelican, travis, ci, travis-ci, s3, github, pages, static
Status:      published
Updated:     2017-05-21 22:00
many years ago I created my own webpage, it all started with pure, HTML evolved to a wordpress and finally became a [pelican](https://blog.getpelican.com/) based setup. It got served on many different hosting providers but since a few years it's running on [S3](https://visibilityspots.org/aws-migration.html) storage and hosted through cloudfront all over the world.

It's a very fast setup, and once the site has been deployed and every little service has been configured and implemented the only thing I need to do is writing content in [markdown](https://daringfireball.net/projects/markdown/) without having to consider how to deploy or how it will look.

In this post I'll try to describe how I configured every service, connected them to each other and automated them through [travis-ci](https://travis-ci.org).

# pelican

it all starts by initiliazing your pelican framework following the [quickstart](http://docs.getpelican.com/en/3.6.3/quickstart.html) guide. Before you proceed you can configure and write some initial content for your webpage locally and see how it will look like without having it published to the world.

You can choose a [theme](http://docs.getpelican.com/en/3.6.3/pelican-themes.html) of your choose, adding [plugins](http://docs.getpelican.com/en/3.6.3/plugins.html) for various use cases or even [import](http://docs.getpelican.com/en/3.6.3/importer.html) an existing  webpage.

Once you have something you want to publish we can proceed to publish it to the world.

# github

versioning is something very important in my opinion, by doing so you can easily track changes and collaborate with a team on one web project. Also other people can easily propose changes on your website this way through pull requests. Another purpose of using a github repository is the way we could trigger automation which could deploy our project to different hosting providers.

A nice side effect is that you have a backup in the "cloud".

For the different pelican plugins and themes I use [git submodules](https://git-scm.com/docs/git-submodule) so I can easily update them with upstream changes.

# AWS

as I already mentioned I opted for [AWS](https://aws.amazon.com/) to host my blog and some other websites I manage. It's easy to deploy, it's fast and rather cheap compared to other providers, I pay about 30 EUR a year for everything, including domain registration, traffic all over the world and storage.

## IAM

I learned that using dedicated users for every single use case isn't a bad idea. So for this setup we need a dedicated user with pro-grammatic access, which have only full access to S3 and cloudfront only for the distributions we configure. The generated access and secret keys will be used by travis to upload new content to our S3 bucket and invalidate cache. They can be created by following the [documentation](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)

Access for letsencrypt [policy](https://github.com/dlapiduz/certbot-s3front/blob/master/sample-aws-policy.json) needs to be granted to the user which will be used to update the blog.

## route53

Creating your own domain or [migrating](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/MigratingDNS.html) to the DNS service [route53](https://aws.amazon.com/route53/) is a very easy way to manage your domain also on amazon. It's easy in the end after all by having one bill for everything.

The only thing I struggled with was the way to update your nameservers after you migrated the domain and made an error in them when migrating. In the route53 configuration pane it can be found in the "Registered domains" tab and not in the hosted zones! Took me some time to figure out the difference between those 2.

Also don't forget to hide your personal data for the different contacts you configured for every registered domain.

## S3

Amazon [S3](https://aws.amazon.com/s3/) object storage service can be used to serve static files and therefore a static [webpage](http://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html) we will be using this feature to host our pelican based website on.

I found a great [how to](http://stackoverflow.com/questions/28675620/cloudfront-redirect-www-to-naked-domain-with-ssl) on stackoverflow which explains perfectly how you have to create 2 buckets to redirect between www and the naked domain and how to enable https once you have that feature enabled.

## cloudfront

[cloudfront](https://aws.amazon.com/cloudfront/) is amazon's own CDN serving your website around the world on different edge locations. It's easy to [implement](http://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html) with your static S3 based setup too.

Cloudfront caches your site on the different edge locations, by using [cache invalidation](https://renzo.lucioni.xyz/s3-deployment-with-travis/) we can trigger the different locations to update their cache according to the new files when being pushed through travis later on.

# Letsencrypt

[letsencrypt](https://letsencrypt.org/) is a free, automated and open Certificate Authority which can be used in combination with S3 using the [certbot-s3front](https://github.com/dlapiduz/certbot-s3front) tool to get your site served through https.

Since we now have everything in place and your website should already be available hosted on AWS we can now automate the whole setup. Meaning the only thing you'll have to perform afterwards is writing content and pushing to git.

# Travis

[travis](https://travis-ci.org/) is a tool which enables you to easily write automation tasks every time a new commit has been pushed to your repository. Once you've created your account and linked it to github you'll have to enable travis through their GUI on the repositories you want to monitor for automation.

Once you've done that for your [repository](https://github.com/visibilityspots/blog) you'll have to configure some credentials and deploy keys. First you'll need the git deploy key, the process is nicely explained by [Steve Klabnik](https://github.com/steveklabnik/automatically_update_github_pages_with_travis_example). That way you'll have a Github token we'll configure in a bit in our .travis.yaml file.

Besides the github token you'll also need to configure the previously created AWS user access and secret keys in travis so travis will be able to update your S3 bucket and invalidates your caches on cloudfront. You'll need to configure those through the GUI of travis on the particular repository as explained by (renzo)[https://renzo.lucioni.xyz/s3-deployment-with-travis/].

Now the most of the administrative part is done a [.travis.yaml](https://github.com/visibilityspots/blog/blob/master/.travis.yml) file is needed in your repository which contains a list of steps to be performed by travis every time a new commit will be pushed.

The result of your build can be followed on the travis webpage as for example the [build](https://travis-ci.org/visibilityspots/blog) of this page
