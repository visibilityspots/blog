Title:       Simple monitoring
Author:      Jan
Date: 	     2015-05-26 19:00
Slug:	     simple-monitoring
Tags: 	     monitoring, sms, mail, ifttt, raspberry, monitor, ping
Status:      published

As I already wrote about in the past I have a [raspberry pi](https://visibilityspots.com/raspberry-pi.html) running at home. I do also have a VPS running somewhere on the interweb for an owncloud instance.

Being a sysadmin I wanted to know when my home devices become unreachable and when the owncloud instance is down. By mail in the first place if possible by sms message for free in the ideal world.

And guess what, I managed to reach the ideal world to monitor my instances. Over here I'll describe how I managed to do so.

# msmtp

First of all you need to install and configure msmtp

```bash
$ sudo pacman -Syu msmtp
```

The configuration is done in the /etc/msmtprc file, we use [telenet](http://telenet.be) as ISP at home so therefore I used their smtp server details:

```bash
$ sudo vim /etc/msmtprc
  defaults

  # A providers service
  account   telenet
  from      yourmailaddress
  host      out.telenet.be

  # Set a default account
  account default : telenet
```

# mail-alert

Next I wrote a bash script which I could pass some parameters so I could use it in many different situations to sent out mails.

```bash

$ sudo vim /usr/local/bin/mail-alert
  #!/bin/bash
  #
  # Script which sends out mail using the given params

  RECIPIENT=$1
  SUBJECT=$2
  MESSAGE=$3

  echo "To: $RECIPIENT" > .mail
  echo "From: youremailaddress" >> .mail
  echo "Subject: $SUBJECT" >> .mail
  echo "" >> .mail
  echo "$MESSAGE" >> .mail
  echo "" >> .mail

  cat .mail | msmtp $RECIPIENT

  rm .mail -rf
```

This way you can easily sent out mails through the command line and therefore use this command in any of your scripts:

```bash
$ mail-alert recipient@domain.eu "Subject" "Your actual message"
```

# monitor-lan

So now I could actually send out mails through the command line I wrote a little bash script which performs some tests and based on the output triggers the mail-alert command:

```bash
$ sudo vim /usr/local/bin/monitor-lan
  #!/bin/bash
  HOSTS="8.8.4.4 gateway.ip.address"
  COUNT=4
  echo "===========================================================" >> /tmp/monitor-lan.log
  for myHost in $HOSTS
  do
    count=$(ping -c $COUNT $myHost | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1 }')
    if [ $count -eq 0 ]; then
      echo "$myHost was down at $(date)" >> /tmp/monitor-lan.log
      mail-alert recipient@domain.eu "$myHost is down" "This mail is to inform that host $myHost is down (ping failed) at $(date)"
    else
      echo "$myHost was alright ok at $(date)" >> /tmp/monitor-lan.log
    fi
  done
```

You can easily test this command by adding a non-reachable ip to the $HOSTS array and manually execute the monitor-lan command.

```bash
$ monitor-lan
```

You should know have received a mail confirming the ip is down.

# sms

As I already proclaimed I wanted this a step further and receive text messages on my cellphone instead of mails. I achieved this functionality using the service [ifttt](https://ifttt.com/wtf). In general it works as follows.

You create yourself an ifttt account and configure the [sms-alerting](https://ifttt.com/recipes/294447-sms-alerting-triggerd-by-mail) recipe. Once that's done every mail you sent from the specified mail address using the #hashtag in the subject you configured in the mail channel to trigger@recipe.ifttt.com will trigger an sms to the mobile number you specified in the sms channel.

I used the #alert hashtag and therefore needed to reconfigure the monitor-lan script:

```bash
$ vim /usr/local/bin/monitor-lan
  #!/bin/bash
  PING_HOSTS="8.8.4.4 gateway.ip.address"
  COUNT=4
  echo "===========================================================" >> /tmp/monitor-lan.log

  # Reachable
  for myHost in $PING_HOSTS
  do
    count=$(ping -c $COUNT $myHost | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1 }')
    if [ $count -eq 0 ]; then
      echo "$myHost went down at $(date)" >> /tmp/monitor-lan.log
      mail-alert trigger@recipe.ifttt.com "$myHost is down #alert" "$myHost went down (ping failed) at $(date)"
    else
      echo "$myHost was alright at $(date)" >> /tmp/monitor-lan.log
    fi
  done
```

When you now add an unreachable ip and perform a manual test your should see after a while in the recipe log a trigger is been executed and the message should arrive on your mobile.


# remote checks

Until now we only monitored the reachability of nodes through the icmp protocol. You could also perform more functional tests. Like for example login through ssh to a remote host and see if httpd is running.

Before adding the if statement to your existing monitor-lan script you should configure key based authentication between the pi and your remote host. This can easily been done by using the [ssh-copy-id](http://www.thegeekstuff.com/2008/11/3-steps-to-perform-ssh-login-without-password-using-ssh-keygen-ssh-copy-id/) command.

```bash
  if [[ $(su - username -c "ssh remote-node 'ps aux | grep httpd | grep -v grep | wc -l'") != "0" ]]; then
      echo "httpd was up at $(date)" >> /tmp/monitor-lan.log
  else
      echo "httpd went down at $(date)" >> /tmp/monitor-lan.log
      mail-alert trigger@recipe.ifttt.com "Owncloud is down #alert" "Owncloud down (no httpd process running) at $(date)"
  fi
```

# cron

Now everything is functional and in place you can configure a scheduled cronjob for it as root.

```bash
# crontab -e
  # Monitor LAN
  */15 * * * * /usr/local/bin/monitor-lan
```

You have now a rather easy peasy monitoring setup up and running which provides your the most basic monitoring for your different systems totally for free!
