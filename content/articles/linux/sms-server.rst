SMS server using CentOS, kannel and playsms
###########################################
:date: 2012-07-24 11:34
:author: Jan
:tags: centOS, debian, gsm, huawai, kannel, playsms, server, sms, option, globetrotter, falcom, mobile, vikings
:slug: sms-server
:status: published
:modified: 2012-07-24

On this page I will describe the way I went trough to configure an sms gateway using a laptop, `huawei`_ modem, `falcom`_ A2D-1 or the `option`_ Globetrotter hardware using the open source software `kannel`_ & `playsms`_.

The main goal of this project was related to the scouting movement in Belgium I'm active. We wanted to interrogate all of our members who were on a start weekend of the next scouting year. To do this we had the idea to use the sms communication channel. This because almost every youngster has the possibility to send sms messages without a big effort.

To achieve this I searched on the internet and found the `playsms`_ software. Using this software you can easily add an interactive flow to communicate with people using sms. We used the sms quiz where we added some questions with keywords were people could answer to and we replied with a next question.

As mobile provider we choose for `Mobile Vikings`_ a belgium operator with an open-mind. They were very helpfull when I contacted them to see if they could monitor some mobile traffic for my sim.

But before this software can handle your sms messages they have to be captured and received using a SIM card and pushed to the software. This step in the whole process can be done by `kannel`_.

Process using CentOS 6.3 minimal installation
---------------------------------------------
Install some required dependency packages:
::

	# yum install gcc libxml2-devel mysql-server wvdial vim

Looking for the modem:
::

	# wvdialconf /etc/wvdial.conf
	Found a modem on **/dev/ttyUSB0**

Minicom
-------
Before starting configuring the services which were going to communicate with the modem I wanted to make sure I could send text messages with it. To check that functionality I installed the `minicom`_ serial communication program:
::

	# yum install minicom
	# minicom

In this terminal you can control the modem using AT commands. A nice tutorial about those commands is available on `qualityguru`_.

Steps for entering the PIN.
::

	AT+CPIN=XXXX
	OK
	AT+CPIN?
	+CPIN: READY
	OK

Checking if the SMS center is configured:
::

	AT+CSCA?
	+CSCA: "+32XXXXXXXXX",145
	OK

If not configured, configure it by:
::

	AT+CSCA="+32XXXXXXXXX"
	OK

The steps for sending a text message:
::

	AT+CMGF=1
	OK
	AT+CMGS="+32XXXXXXXXX"
	> This is the text message.
	> (CTRL-Z)
	+CMGS: XX
	OK

If you received the message on your phone its working obviously and we can start configuring kannel.

If not, check the `troubleshoot`_ page of qualityguru for some common mistakes.

Kannel
------
At the moment of writing this post the last stable version is 1.4.3. Using CentOS 6.4 you can install kannel from the epel `repository`_:
::

        # yum install kannel

Or you can choose to compile it from source:
::

        # wget http://www.kannel.org/download/1.4.3/gateway-1.4.3.tar.gz
        # tar zxvf gateway-1.4.3.tar.gz -C /usr/local/src/
        # cd /usr/local/src/gateway-1.4.3/
        # mkdir -p /etc/kannel
        # ./configure --prefix=/etc/kannel
        # make
        # make install

I installed the kannel service from the repository and created a symlink from /etc/kannel.conf to the /etc/kannel/kannel.conf so the playsms service could read the configuration afterwards:
::

	# mkdir /etc/kannel/
	# ln -s /etc/kannel.conf /etc/kannel/kannel.conf

Once you configured your device you start kannel by starting the kannel service:
::

	# service kannel start

If everything went well you can see that there are 2 services started:
::

	# ps aux | grep kannel
	kannel    9611  1.9  0.1 750424  6684 ?        Sl   13:14   2:37 /usr/sbin/bearerbox /etc/kannel.conf
	kannel    9636  0.0  0.1 674228  4676 ?        Sl   13:14   0:00 /usr/sbin/smsbox /etc/kannel.conf

In the /var/log/kannel/kannel.log file you can follow the state of the kannel service. I struggled a bit with this to find out the reset string for the modems I used. By searching the internet you can find the particular string for your device.

For example the option one I found on `enterprisemobiletoday.com`_ by try & error in the minicom terminal.

I used different sorts of hardware and listed the specific kannel.conf files here under per device.

In the first phase I used a `huawei`_ USB dongle:

::

        #CORE
        group = core
        admin-port = 13000
        admin-password = #PASSWORD
        status-password = #PASSWORD
        log-file = "/var/log/kannel/kannel.log"
        log-level = 0
        access-log = "/var/log/kannel/access.log"
        smsbox-port = 13001
        store-type = file
        store-location = "/var/log/kannel/kannel.store"*

        #SMSC MODEM GSM
        group = smsc
        smsc = at
        connect-allow-ip = 127.0.0.1
        port = 13013
        host = "localhost"
        smsc-id = Huawei
        modemtype = Huawei
        device = /dev/ttyUSB0
        speed = 9600
        sms-center = "+32486000005"
        my-number = "+324XXXXXXXX"
	pin = XXXX

        group = modems
        id = huawei
        name = huawei
        detect-string = "huawei"
        init-string = "AT+CNMI=2,1,0,0,0;+CMEE=1"

        #SMSBOX SETUP
        group = smsbox
        bearerbox-host = 127.0.0.1
        bearerbox-port = 130X01
        sendsms-port = 13131
        sendsms-chars = "0123456789+"
        global-sender = 00324XXXXXXXX
        log-file = "/var/log/kannel/smsbox.log"
        log-level = 0
        access-log = "/var/log/kannel/access.log"

        #SEND-SMS USERS
        group = sendsms-user
        username = #USERNAME
        password = #PASSWORD
        user-allow-ip = "\*.\*.\*.\*"

        #SMS SERVICE
        group = sms-service
        keyword = default
        accept-x-kannel-headers = true
        #accepted-smsc = Huawei
        accepted-smsc = at2
        max-messages = 0
        assume-plain-text = true
        catch-all = true

        get-url = "http://localhost/playsms/index.php?app=call&cat=gateway&plugin=kannel&access=geturl&t=%t&q=%q&a=%a"

During the event was in the possession of a `falcom`_ A2D-1 gateway which was connected from serial to usb:
::

        group = core
        admin-port = 13000
        admin-password = playsms
        log-file = "/var/log/kannel/kannel.log"
        log-level = 0
        access-log = "/var/log/kannel/access.log"
        smsbox-port = 13001
        store-type = file
        store-location = "/var/log/kannel/kannel.store"*

        group = smsc
        smsc = at
        modemtype = falcom
        device = /dev/ttyUSB0
        my-number = "+324XXXXXXXX"
        sms-center = "+32486000005"
	pin = XXXX

        group = modems
        id = falcom
        name = "Falcom"
        detect-string = "Falcom"
        reset-string = "AT+CFUN=1"

        #SMSBOX SETUP
        group = smsbox
        bearerbox-host = localhost
        sendsms-port = 13131
        log-file = "/var/log/kannel/smsbox.log"
        log-level = 0
        access-log = "/var/log/kannel/access.log"

        #SEND-SMS USERS
        group = sendsms-user
        username = #USER
        password = #PASSWORD

        #SMS SERVICE
        group = sms-service
        keyword = default
        accept-x-kannel-headers = true
        max-messages = 0
        assume-plain-text = true
        catch-all = true

        get-url = "http://127.0.0.1:2080/playsms/index.php?app=call&cat=gateway&plugin=kannel&access=geturl&t=%t&q=%q&a=%a"

After the event I had to give back the falcom and got my hands on an `option`_ globetrotter HSPDA card connected on a pcmci slot of the laptop I configured as CentOS server:

::

	#CORE
	group = core
	admin-port = 13000
	admin-password = playsms
	status-password = playsms
	log-file = /var/log/kannel/kannel.log
	log-level = 0
	access-log = /var/log/kannel/access.log
	smsbox-port = 13001
	store-type = file
	store-location = /var/log/kannel/kannel.store

	#SMSC MODEM GSM
	group = smsc
	smsc = at
	connect-allow-ip = 127.0.0.1
	port = 13013
	host = “localhost”
	smsc-id = Option
	modemtype = Option
	device = /dev/ttyUSB0
	speed = 9600
	sms-center = "32486000005"
	my-number = "324XXXXXXXX"
	pin = XXXX

	# If modemtype=auto, try everyone and defaults to this one
	group = modems
	id = generic
	name = "Generic Modem"
	reset-string = "AT&F"

	#SMSBOX SETUP
	group = smsbox
	bearerbox-host = 127.0.0.1
	bearerbox-port = 13001
	sendsms-port = 13131
	sendsms-chars = “0123456789+”
	global-sender = 0032485550261
	log-file = “/var/log/kannel/smsbox.log”
	log-level = 0
	access-log = “/var/log/kannel/access.log”

	#SEND-SMS USERS
	group = sendsms-user
	username = playsms
	password = playsms

	#SMS SERVICE
	group = sms-service
	keyword = default
	accept-x-kannel-headers = true
	accepted-smsc = at
	max-messages = 0
	assume-plain-text = true
	catch-all = true

Web service
-----------
For the playsms service we need to have a webserver configured. You can use every webserver you want, I tried with xampp and lighttpd.

During the event I used with the xampp web service because it was working after all by following the howto of `kasrut`_.

After the event was finished I migrated to lighttpd mainly because I already had some other applications running on that service.

**Xampp**
::

	# wget http://nchc.dl.sourceforge.net/project/xampp/XAMPP%20Linux/1.7.4/xampp-linux-1.7.4.tar.gz
	# tar zxvf xampp-linux-1.7.4.tar.gz -C /opt/
	# cd /opt/lampp
	# ./lampp start

**Lighttpd**

For the installation of lighttpd I refer to a clear tutorial on `howtoforge`_

playsms
-------

`playsms`_ is a free and open-source gateway. I used this software to configure a big quiz to set up a cool and trendy communication flow between people and our scouting movement.

I used the `git`_ repository to easily update my instance to the newest releases:

::

	# cd /usr/local/src/
	# git clone git@github.com:antonraharja/playSMS.git
	# cd playSMS/

Creation of the necessary directories and copy the web files to the webserver directory

::

	# mkdir -p /var/www/html/playsms /var/spool/playsms /var/log/playsms /var/lib/playsms
	# cp -r usr/local/src/playSMS/web/* /var/www/html/playsms/

Creation of a mysql db and user:

::

	# mysql -u root -p
        # Enter password:


	# mysql> create database playsms;
	Query OK, 1 row affected (0.00 sec)

	# mysql> grant usage on *.* to USER@localhost identified by ‘PASSWORD’;
	Query OK, 0 rows affected (0.00 sec)

	# mysql> grant all privileges on playsms.* to USER@localhost ;
	Query OK, 0 rows affected (0.00 sec)

	# mysql> quit

	# msql -u root -p playsms < /usr/local/src/playSMS/db/playsms.sql

Next step is to configure the playsms web service. Therefore follow those steps:
::

	# cd /var/www/html/playsms
	# cp config-dist.php config.php

Edit this config.php file to your own needs.

Now we configured the parameters we can start to install the services:
::

	# mkdir -p /etc/default /usr/local/bin
	# cp /usr/local/src/playSMS/daemon/linux/etc/playsms /etc/default/
	# cp /usr/local/src/playSMS/daemon/linux/bin/* /usr/local/bin/
	# vim /etc/default/playsms # edit the paths to your environment ones

I've used rc.local to start the service at boot:
::

	# vim /etc/rc.d/rc.local

and put /usr/local/bin/playsmsd_start at the end of that file

Next I configured 2 new aliases in my ~/.bashrc to easily start and stop the service:
::

	alias playsms-start='/usr/local/bin/playsmsd_start'
	alias playsms-stop='/usr/local/bin/playsmsd_stop'

By re-logging in you can start the service by:
::

	# playsms-start

And check if the necessary services are started:
::

	# ps aux | grep playsms
	root      7735  0.0  0.0 103236   868 pts/4    S+   15:52   0:00 grep playsms
	root     21845  0.0  0.0 106312  1660 pts/4    S    12:25   0:06 /bin/bash ./playsmsd /var/www/html/playsms
	root     21847  0.0  0.0 106184  1536 pts/4    S    12:25   0:05 /bin/bash ./sendsmsd /var/www/html/playsms

Finally you can browse http://<your web server IP>/playsms/ and login using
      username: admin
      password: admin

Where you need to configure kannel in the menu: Gateway > Manage Kannel > kannel (Inactive) (click here to activate) and adopt the parameters to the ones you configured in kannel.conf

After filling in your preferences you should be able to send and receive messages through this nifty web console.

(TIP: Using twice the same keyword for a quiz resulted in the fact that only this word is needed to send to the sms server to start the interactivity)

Have fun with it!

.. _playsms: http://playsms.org/
.. _kannel: http://www.kannel.org/
.. _howtoforge: http://www.howtoforge.com/installing-lighttpd-with-php5-php-fpm-and-mysql-support-on-centos-6.3
.. _kasrut: http://kasrut.blogspot.be/2011/07/install-playsms-and-kannel-on-centos-6.html
.. _repository: http://fedoraproject.org/wiki/EPEL
.. _falcom: http://www.falcom.de
.. _huawei: http://www.business.vodafone.com/site/bus/public/enuk/support/10_productsupport/usb_stick/01_vodafone/02_vodafone_k3565/20_software/p_software.jsp
.. _option: http://www.option.com/support/globe-trotter-hsdpa
.. _minicom: http://linux.die.net/man/1/minicom
.. _qualityguru: http://qualityguru.wordpress.com/test-status-to-smsmms/
.. _troubleshoot: http://qualityguru.wordpress.com/2010/03/02/test-status-to-smsmms-trouble-shooting-sending-sms-messages-with-dedicated-gsm-modem-device/
.. _enterprisemobiletoday.com: http://forums.enterprisemobiletoday.com/showthread.php?50854-Getting-Vodafone-s-Option-Globetrotter-to-work
.. _git: https://github.com/antonraharja/playSMS
.. _Mobile Vikings: http://www.mobilevikings.com
