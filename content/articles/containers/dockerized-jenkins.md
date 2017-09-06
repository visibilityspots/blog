Title:       Dockerized jenkins master/slave setup
Author:      Jan
Date: 	     2017-09-06 22:00
Slug:	     dockerized-jenkins
Tags: 	     docker, jenkins, master, slave, centos, 7
Status:	     published

Updated:     2017-09-06 22:00

started at a new customer we were looking for a more flexible way of having jenkins spinning up slaves on the fly. This in a way a slave is only started and consuming resources when a specific job is running. That way those resources could be used more efficient.

Also the fact that developers could take control over their build servers by managing the Dockerfiles themselves is a great advantage too. But that's for a later phase. Let's start at the beginning.

For the docker host a CentOS 7 server has been provisioned and prepared to run the docker daemon. Starting with updating the OS, removing unnecessary services and implementing NTP.

```
# yum upgrade -y

# systemctl stop postfix
# systemctl disable postfix
# yum remove postfix

# systemctl stop chronyd
# yum remove chrony -y

# reboot

# yum install ntp
# systemctl start ntpd
# systemctl enable ntpd
# ntpdate
# date
```

Once the system has been prepared we can start with the installation of the docker daemon using the upstream [docker community edition](https://www.docker.com/community-edition) repository

```
# yum install -y yum-utils device-mapper-persistent-data lvm2
# yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# yum clean all
# yum makecache fast
# yum install docker-ce
# systemctl start docker
# systemctl enable docker

# docker run hello-world
Hello from Docker!
This message shows that your installation appears to be working correctly.
...

# docker info
```

we do now have a basic docker daemon running on a CentOS 7 machine. The next thing to do is to start a jenkins master docker container. Before doing so some decisions need to be made.

Docker containers are stateless, meaning when the container is gone, the data is gone too. With this taken into account and assuming it's a proof of concept I decided to mount a directory on the host to the jenkins master container.

Since the pipeline plugin will be used, all job configurations are residing in Jenkinsfiles. The needed plugins can be passed through the docker run command later on so that's covered as well.

When the setup is ready for production we could look which directories are needed to be persistent and decide to mount only those needed. But for starters we go for a full mount of the jenkins home directory.

Therefore we need to create a jenkins user on the docker host which is the owner of the local directory which will be used afterwards to mount onto the jenkins master docker container.

```
# mkdir /opt/jenkins
# chown -R 1000: /opt/jenkins
```

before we can start using this very same docker host through our jenkins instance we need to open up the API port of our docker daemon. This can be configured in the systemd entity of the docker daemon:

```
# mkdir -p /etc/systemd/system/docker.service.d/
# cat /etc/systemd/system/docker.service.d/docker.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock
# systemctl daemon-reload
# systemctl restart docker.service
# systemctl status docker.service
* docker.service - Docker Application Container Engine
Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; vendor preset: disabled)
Drop-In: /etc/systemd/system/docker.service.d
- docker.conf
Active: active (running) since Thu 2017-07-20 13:43:22 CEST; 2 weeks 5 days ago
Docs: https://docs.docker.com
Main PID: 5858 (dockerd)
Memory: 4.2G
CGroup: /system.slice/docker.service
|- 5858 /usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock
|- 5866 docker-containerd -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontainerd/containerd --shim docker-containerd-shim --runtime docker-runc
...
```

we now have the API listening to tcp port 2375 but the port is still filtered by our firewall. To configure the firewall add the port to the appropriate zone and interface. Also the range 32000-34000 which is used by jenkins to access the slaves through ssh is needed to be accessible:

```
# firewall-cmd --permanent --add-port=2375/tcp
# firewall-cmd --permanent --zone=trusted --change-interface=docker0
# firewall-cmd --permanent --zone=trusted --add-port=2375/tcp
# firewall-cmd --permanent --zone=public --add-port=32000-34000/tcp
# firewall-cmd --reload

# yum install -y nmap
# nmap -p 2375 ip.of.docker.host

Starting Nmap 6.40 ( http://nmap.org ) at 2017-08-09 10:29 CEST
Nmap scan report for 10.11.1.17
Host is up (1500s latency).
PORT     STATE SERVICE
2375/tcp open  unknown

Nmap done: 1 IP address (1 host up) scanned in 0.05 seconds

# curl -X GET http://localhost:2375/images/json
```

and we are off to go, a docker container can be started using the [official upstream image](https://hub.docker.com/r/jenkins/jenkins/) from jenkins. They also did a great job on [documentation](https://github.com/jenkinsci/docker/blob/master/README.md) about those docker images. We went for the lts release because this setup will be the production one in the future.

```
# docker run -d -p 8080:8080 -v /opt/jenkins/:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkinsci/jenkins:lts
```

as you can see we passed through the [docker unix socket](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/) from the host to the jenkins container by doing so we are now able to instruct actions on the docker host from within our jenkins instance.

on your docker host a jenkins container is running and accessible through the docker host's ip address on port 8080 which is forwarded to the jenkins master docker container. To have access to the container himself or follow the logs:

```
# docker ps
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS                               NAMES
d28838216442        jenkinsci/jenkins:lts   "/bin/tini -- /usr..."   19 hours ago        Up 19 hours         0.0.0.0:8080->8080/tcp, 50000/tcp   determined_bartik
# docker exec -i -t --user root d28838216442 /bin/bash
# docker logs -f d28838216442
```

the plugin needed to communicate with our docker host is the [docker plugin](https://wiki.jenkins.io/display/JENKINS/Docker+Plugin) following the configuration as described in their documentation we created a docker cloud which will be used to execute builds with a specified label only. This is very handy because we can now create different docker images for every piece of software with other dependencies.

For the initial testing setup we used the upstream docker image [evarga/jenkins-slave](https://hub.docker.com/r/evarga/jenkins-slave/).

## docker cloud configuration
Manage Jenkins -> Configure System: Cloud - Add new cloud: Docker Cloud

| Name | Value|
|------|-------|
| Name | testdocker|
| Docker URL	| tcp://ip.address:2375 |
| Connection Timeout | 15 |
| Read Timeout | 5 |
| Container Cap	| 100 |

-> Add Docker Template

| Name	| Value	|
|------|-------|
| Docker Image	| evarga/jenkins-slave:latest	(the tag can be pinpointed for production)
| Container Settings | |
| Volumes | /var/run/docker.sock:/var/run/docker.sock |
| Remote Filing System Root | /home/jenkins |
| Labels | generic |
| Usage	| Only build jobs with label expressions matching this node |
| Launch method	| Docker SSH computer launcher|
| Credentials |	jenkins (A dedicated SSH key pair for jenkins use cases) |
| Host Key Verification Strategy | Manually provided key Verification Strategy |
| SSH-KEY | the private SSH key for the jenkins slave user |
| Remote FS Root Mapping | /home/jenkins |
| Remove volumes | true |
| Pull strategy	| Pull once and update latest |

Depending on the label specific docker images will be used to execute the job and store the result in a repository.

Along the way I struggled with setting up the docker cloud. In the first place because we are abusing the same docker host as our jenkins container is running on. By passing through the docker socket and opening up a range of ports used by jenkins to SSH into the slaves I finally achieved a running job which spawns a docker container and destroys him as soon as the job is done.

## custom jenkins master image

to get the docker plugin working nicely the docker daemon needs to be installed on the jenkins instance too. Therefor I created a new [jenkins-docker](https://hub.docker.com/r/visibilityspots/jenkins-docker/) docker image which is based on the upstream jenkins:lts image but adds the docker daemon and staticly configure the docker GID to prevent mismatches between the docker socket mounted on the container from the host.

to have the daemon mounted from the host in the jenkins containers, both master as slave should be able to execute docker commands over the socket the docker group need to have the same GID on all containers and 'physical' machines. Since we statically changed this GID already on the containers we also need to map this GID on the physical machine:

```
# groupmod -g 900 docker
# systemctl restart docker.service
```

The container is started with some extra parameters like the java_opts one for the allocation of RAM memory for the jenkins daemon.
```
# docker run -d -p 8080:8080 -v /opt/jenkins/:/var/jenkins_home -e JAVA_OPTS="-Xmx6144m" -v /var/run/docker.sock:/var/run/docker.sock visibilityspots/jenkins-docker:latest
```
