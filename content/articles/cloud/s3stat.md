Title:       S3stat
Author:      Jan
Date: 	     2016-10-26 19:00
Slug:	     s3stat
Tags: 	     s3stat, aws, analytics, statistics, web, refers, s3, cdn, cloudfront
Status:      published

Some weeks ago an article on [hacker news](https://news.ycombinator.com/item?id=12634447) got my interest. From time to time I really get an healthy dose of jealousy when people found an idea which could make them buy a tesla. My terms of someone who make a lot of money ;)

This one is so brilliant in it's simplicity that I really was flabbergasted and made me wonder why I never came up with the idea. It generates nice reports of the usage of your site which is hosted by aws. Based on the logs of the S3 bucket or the cloudfront domain you setted up.

As I [blogged](../aws-migration.html) about a few months ago I migrated my blog as static content onto an S3 bucket and serve it through the CDN of amazon to the world for a really cheap price. I manage my blog with [pelican](http://blog.getpelican.com) which makes a beautiful static website based on markdown files. One of the features is the [google analytics](http://docs.getpelican.com/en/latest/settings.html?highlight=analytics#themes) component which sends data through the browser of the visitor. Which can be blocked off course through some inventive add blocking features of the used browser.

So I was trilled when logging creating an account on [s3stat](https://s3stat.com) to see what my data is all about in their visual reports. I started by adding my S3 buckets which obviously didn't have logging enabled. I disabled them back in the days when migrating since I didn't saw a use case for them at that moment. This feature can easily be enabled using the separate aws account I created by following their how to guide.

It took a while before the first data got through their website but after a day or two I had some nice and simple reports about the usage of my S3 buckets. One of my blog and one of my custom [vagrant boxes](https://atlas.hashicorp.com/visibilityspots). Besides the delay of about one day I could see what I needed to see.

In comparison with google analytics they offer some more details especially the referral pages are quite interesting to me which is like the only feature I miss in S3stat, they do show your referral pages, but every single page of the website itself is also seen as a referral page. Which kinda creates a lot of pages and it's hard to find the relevant information of external pages.. Google analytics isn't live data neither and since s3stat can't be blocked by some browser plugins they offer more accurate data about your content usage. Another nice feature are the costs, they give you an idea which of the requests is costing you money. Which could be interesting to see if you could adopt your website so it can be cheaper to host it at AWS..

It took some time to get the cloudfront instances coupled, the interface did found the instances but it froze when I selected on of the cloudfront distributions. After a week or two I finally managed to select them and get them coupled through s3stat. My best guess is that the success of the default setting took down some services. I created a support ticket for it but didn't got an answer so far. Guess they are very busy to keep the service up and running.

Since it's working fine now I don't bother about it :) I do have now nice statistics of my blog which is really great and I love it. The only reason I still connect to google analytics are the detailed information about referral websites..

One of the sad parts is the pricing. For my blog it would take about $ 10 each month. Since I only pay $ 2 dollar on average to host it that isn't something I'm willing to pay for those statistics. But I stumbled on their [cheap bastard plan](https://www.s3stat.com/web-stats/cheap-bastard-plan) which is the mean reason I wrote a blog post about it.

And because of my empathy with their simplicity :)

I only had trouble the first time I wrote a new article after I setted up s3stat. I'm using [s3cmd](http://s3tools.org/s3cmd) to upload new pages to the S3 bucket. And the sync command was deleting the log directory which includes all log entries.. So I had to add the exclude parameter to my s3cmd sync command;

```
 --exclude 'log/*'
 ```

 This was a huge mistake from my end. Luckily the files aren't that critical I only lost a few days of them since so nothing to bother about in the end..
