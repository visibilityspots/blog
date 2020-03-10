Title:       Httpd semaphores
Author:      Jan
Date:        2020-03-09 19:00
Slug:        httpd-semaphores
Tags:        apache, httpd, semaphores, error, no, space, left, on, device
Status:      published
Modified:    2020-03-09

Recently we encountered some strange issues with httpd on some of our CentOS 7 machines during my current project.

Through our pipeline we restart httpd several times which sometimes leads to this error:

```
Apache: [error] (28)No space left on device
```

After some research we found out the semaphores were all being used blocking httpd daemon to restart.

The list of semaphores can be fetched by issuing

```
# ipcs -st

------ Semaphore Operation/Change Times --------
semid    owner      last-op                    last-changed
753664   apache      Not set                    Mon Feb 17 20:20:47 2020
786433   apache      Not set                    Mon Feb 17 20:20:47 2020
720898   apache      Not set                    Mon Feb 17 20:20:47 2020
819203   apache      Not set                    Mon Feb 17 20:20:47 2020
851972   apache      Tue Feb 18 10:04:36 2020   Mon Feb 17 20:20:47 2020
884741   apache      Tue Feb 18 10:04:36 2020   Mon Feb 17 20:20:47 2020
1540102  apache      Not set                    Wed Feb 19 22:57:02 2020
1572871  apache      Not set                    Wed Feb 19 22:57:02 2020
1507336  apache      Not set                    Wed Feb 19 22:57:02 2020
1605641  apache      Not set                    Wed Feb 19 22:57:02 2020
1638410  apache      Thu Feb 20 11:16:48 2020   Wed Feb 19 22:57:02 2020
1671179  apache      Thu Feb 20 11:16:48 2020   Wed Feb 19 22:57:02 2020
3276812  apache      Not set                    Sun Feb 23 20:18:54 2020
3309581  apache      Not set                    Sun Feb 23 20:18:54 2020
3244046  apache      Not set                    Sun Feb 23 20:18:54 2020
3342351  apache      Not set                    Sun Feb 23 20:18:54 2020
3375120  apache      Mon Feb 24 11:30:21 2020   Sun Feb 23 20:18:54 2020
3407889  apache      Mon Feb 24 11:30:21 2020   Sun Feb 23 20:18:54 2020
3538962  apache      Not set                    Mon Feb 24 11:30:21 2020

```

Open connections are not cleared while restarting the httpd daemon in our case unfortunately which leads after some time into the error.

We did found out that clearing those semaphores fixed the issue. Initially we did this manually by executing a for loop;

```
# ipcrm sem $(ipcs -s | grep apache | awk '{print$2}')
```

Obviously we didn't wanted to wait for our alerting or colleagues to shout when the httpd daemon is stuck. So we configured the ExecStopPost parameter of the httpd systemd unit.

This is done by simply adding a drop in configuration file for that unit

```
# cat /etc/systemd/system/httpd.service.d/clean-semaphores.conf
[Service]
ExecStopPost=/usr/bin/ipcs -s | awk '$3 == "apache" {system("ipcrm sem " $2)}'
```

This will clean out the left over semaphores when the httpd daemon has been stopped right before it starts again.

references;

- [https://access.redhat.com/solutions/78873](https://access.redhat.com/solutions/78873)
- [https://www.crybit.com/semaphores-linux/](https://www.crybit.com/semaphores-linux/)
