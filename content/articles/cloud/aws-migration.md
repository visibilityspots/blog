Title:       AWS migration
Author:      Jan
Date: 	     2016-09-18 21:00
Slug: 	     aws-migration
Status:      published
Tags:	     aws, awsome, awesome. cloud, amazon, migration, pelican, rds
Modified:     2017-03-17

About a year ago I attended the [AWSome Day](http://aws.amazon.com/events/awsome-day/benelux/belgium/) at [Mechelen](http://lamot-mechelen.be). Back then I wrote a first draft article about it, but it got out of my sight unfortunately. I reviewed it and decided to publish it anyway.

The event was based on their essentials course and took use through the different AWS core services (compute, storage, database and network).

I do know it has nothing to see with open-source. But it is a part of that ultimate cloud based setup I believe in which exists in one central place from where you can manage all your virtual machines independent of which stack/service it uses.

In that ultimate setup the public cloud is important to me too. And when you look at public clouds, amazon can't just be ignored in my opinion. That should give you the flexibility to extend your infrastructure when needed, add the ability to benchmark applications between different virtualization / storage resources and make managing them easier without having to open up way too many management consoles.

# The course

the course itself was intended for both technical as management background profiles. The goal of it was merely to highlight the different products and what you can technically achieve with them as well as how they could be combined.

## introduction

Starting with an introduction on the different AWS services and the console going over the many different options, unfortunately the live demos where postponed since the speaker forgot his charger.

## storage

After the introduction the different storage services provided by AWS where enlighted, focusing on the [S3](http://aws.amazon.com/s3/details/) and [EBS](http://aws.amazon.com/ebs/details/) instances. Where clearly told the first one is an object storage system and the second one can be used to deploy filesystems on it.

## console demo

The speaker also pulled my attention by mentioning you could serve a static website on an S3 instance. Since you only buy for what you use this has been the trigger for me to start looking into migrating my current blog to an amazon hosted one. Which I'll describe further on in this post.

Once he got his charger back the speaker showed us the aws management console and the different options and features you could use. During the demo he also pointed to the [security best practices](http://aws.amazon.com/whitepapers/aws-security-best-practices/) like having MFA enabled, not using your root account and such..

So I went buy myself an [ezio display card](http://onlinenoram.gemalto.com/) to enhance my geeky nerd state.



## compute services and networking

Next topic of the day concerned the different services of computing instances and networking. Starting with the [EC2](http://aws.amazon.com/ec2/details/) by explaining their different tastes and flavors depending on what you want to achieve.

Also a tip of the speaker was to benchmark the application you want to provision on different types of instances. It only costs you the amount of time running the benchmark tests. But in the end you should have found the right instance for what you are trying to achieve at a reasonable price in the long term!

## databases

two types of databases are briefly touched first the [RDS](https://aws.amazon.com/rds/) one which is the more classic alternative amazon provides.

And the [dynamodb](https://aws.amazon.com/dynamodb/) which is like the nosql database managed cloud service.

And when this all is what you were looking for you could start perhaps your own amazon based [Virtual Private Cloud](http://aws.amazon.com/vpc/details/)


# open guides

I stumbled onto [open guides](https://github.com/open-guides/og-aws) for aws which is a collection of very useful information and references for every aws service combined with how-to guides and such. Very useful when playing around with the AWS services and need information about one of them!

# dynamic DNS

It is even possible to get rid of all the free dyndns services you are using and use the route53 API to update your DNS names for certain appliances. By following the guide of [Will Warren](https://willwarren.com/2014/07/03/roll-dynamic-dns-service-using-amazon-route53/) I now have my own domain name used for dynamic DNS names.

# Static blog

During the presentation the speaker mentioned you could host a static website on an amazon S3 instance. A couple of years ago I migrated my blog to a [pelican](http://getpelican.com) based one. This tool allows you to write your articles in markdown and convert those into a static html based instance. Since I don't need interactivity for my blog it's the perfect solution to me. The only aspect I need to take into account is to write the actual content. So I don't have to focus about the other stuff like layout and such.

I used to host my website on a traditional hosting service called [one.com](http://one.com). Costs me about 30 EUR a year for some web space and a domain name. Since it felt like a great exercise to get to know the different AWS services I decided to host my blog on those technologies as a proof of concept to start with.

I followed the [tutorial](http://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html) from the aws documentation to get it up and running.

Using the cloudfront functionality the content of my static blog from the s3 instance will be populated through the different edge locations of the [CloudFront Global Edge Network](http://aws.amazon.com/cloudfront/details). By linking my new domain name visibilityspots.org which is a [Route 53](http://aws.amazon.com/route53/details/) instance to the cloudfront instance, the end users requests are automatically routed to the nearest edge location for high performance delivery of your content.

This makes my blog super fast on any continent for a rather cheap price!

I once read an article about the https encryption on the internet. The author believed in a world where only encrypted web traffic should exist so nobody has to care about anymore if their data is encrypted on the web. My blog doesn't has any use case where I really need this encryption. But once again it's a great exercise to set it up to get a feeling how this stuff actually works.

So I went for a [start ssl](https://www.startssl.com/) domain ssl certificate which costs me nothing but a monthly reactivation mail. This certificate I uploaded to my aws account, as described by [Bryce Fisher](https://bryce.fisher-fleig.org/blog/setting-up-ssl-on-aws-cloudfront-and-s3) so I could start using it to serve my blog with the world through an encrypted line.

In the meantime [letsencrypt](https://letsencrypt.org/) was founded and I switched my start ssl certificate to a letsencrypt one. Using the [letsencrypt-s3front](https://github.com/dlapiduz/letsencrypt-s3front) tool from [Diego Lapiduz](https://github.com/dlapiduz) this got really easy, and I even got it automated through my [pi](../raspberry-pi.html) so every x months the certificate is renewed and I get a notification through [ntfy](http://ntfy.readthedocs.io/en/latest/) on telegram about it as soon as it's done.

## Price

I have my blog served by AWS about more then a year now and it costs me about $ 1.5 every month. With the annual fee of $ 12 for the domain name it costs me about the same as before at one.com. Only now my blog is supersonic fast and available through amazons cloudfront service.

## Benchmarks

I did a test using the [siege](https://www.joedog.org/siege-home/) software on 4 different platforms where I do host my blog. The one.com hosting which is serving the visibilityspots.com domain, the github pages one, the s3 instance directly and the cloudfront cached visibilityspots.org domain.

I did expected the one.com domain would be ending at the bottom of the performance tests. Which did indeed turns out as I thought. Rather unexpected was the platform of github scoring the highest on the test. I could have directed my DNS to the github pages but over the time I experienced some down time of github from time to time. It's not that I could save a lot of money by using github so I decided to keep AWS cloudfront as my primary hosting partner.

I decided to execute the benchmarks once again after more than one year and as you can see the results are a lot better compared to a year ago. And my decision to stick with AWS has payed of as you can see they are a lot faster than github those days.
```bash
# siege -b -t5M http://visibilityspots.github.io/blog/
Date & Time,	     Trans,  Elap Time,  Data Trans,  Resp T,  Trans R,  Thrghput,    Concur,      OKAY,  Fail
2015-06-03 22:35:02, 2794,   299.46,     47,          0.11,    9.33,     0.16,        1.00,        2794,  0
2016-09-18 19:31:23, 14293,  299.94,     24,          0.41,    47.65,    0.08,        19.39,       14293, 1

# siege -b -t5M	http://visibilityspots.org
2015-06-03 22:40:45, 2642,   299.14,     44,          0.11,    8.83,     0.15,        1.00,        2642,  0
2016-09-18 19:38:46, 16613,  299.90,     79,          0.44,    55.40,    0.26,        24.44,       16614, 0

# siege -b -t5M http://visibilityspots.org.s3-website-eu-west-1.amazonaws.com/
2015-06-03 22:52:32, 1686,   299.03,     28,          0.18,    5.64,     0.09,        1.00,        1686,  0
2016-09-18 19:45:07, 14063,  299.40,     73,          0.53,    46.97,    0.24,        24.66,       14063, 0

# siege -b -t5M http://visibilityspots.com
2015-06-03 22:27:47, 1617,   299.56,	 27,          0.19,    5.40,     0.09,        1.00,        1617,  0
```

Since the results of all those actions where rather satisfying I decided to migrate all the services I had at one.com to AWS. By using a second domain I could play around without interrupting my existing services. Once each one of them was running I redirected the DNS records to the .org ones.

A static blog on S3, a mail service, [OWA](http://www.openwebanalytics.com/) instance, my little roomba project and an [owncloud](https://owncloud.org) S3 storage were running on amazon. I still had a VPS running in the field serving an owncloud instance which I used for my calendars (caldav) and address books (carddav) syncing with my laptop [vdirsyncer](https://vdirsyncer.pimutils.org/en/stable/) and my android phone [davdroid](https://davdroid.bitfire.at/) and sharing pictures with the family.

Since the performance of the photo page was rather unsatisfying, and storage became an issue I bought myself a Synology [DS214play](https://www.synology.com/en-us/support/download/DS214play) NAS so I migrated all my services to my own little cloud storage running at home. Right now only my blog is served on AWS and all other services are running on my NAS. I don't rely on the public cloud anymore for any of my services.

Only an offsite backup of some of my encrypted data containers is synced once in a while through [glacier](https://aws.amazon.com/glacier/). Which is only used in case of geological disaster happens and both my parents and parents-in-law computes devices are destroyed together with my own (which are in sync using [syncthing](https://syncthing.net/) and my off site backup disk at work got destroyed. Which really sounds paranoia now I write about it :)

I moved all this because of some privacy matters I have regarding all the public cloud services provides.

And until today that combination really worked out very well. I don't loose a lot of time in maintaining the different platforms but I can focus on using and configuring new services like home automation using home-assistant, a wemos sensor framework, and many more. 

Which I will blog about in the future.
