Title:       Nexus OSS repository manager
Author:      Jan
Date: 	     2017-09-11 19:00
Slug:	     nexus-oss-repository-manager
Tags: 	     nexus, repository, manager, nginx, proxy, SSL, https, docker, private, group
Status:      published
Modified:    2017-09-11

looking for a global repository store which could store maven projects, yum repositories, docker repositories, we bumped into [Nexus repository manager](https://help.sonatype.com/display/NXRM3/Repository+Manager+3). We used the official docker image to see how it can be implemented in the dockerized CI environment.

## docker repository

as a first the docker repository feature could be enabled so we can start building and storing docker images for the different jenkins build slaves and the jenkins master so our work is reproducible and stored in a safe central place.

We configured 3 repositories in nexus for our docker images seen as a recommended approach in the [nexus documentation](https://help.sonatype.com/display/NXRM3/Private+Registry+for+Docker#PrivateRegistryforDocker-HostedRepositoryforDocker(PrivateRegistryforDocker)). Each of them are configured to their own separate blob store.

| Name	 | | Purpose |
|--------|-|---------|
|private | | self hosted docker repository where all the internal images will be stored |
|proxy	 | | cached proxy which will download every request from docker hub and caches to reduce download but also for having an offline backup of upstream images |
|group	 | | group which combines the first 2 repositories behind one URL |

### configuration

by following a tutorial from [Ivan Krizan](https://www.ivankrizsan.se/2016/06/09/create-a-private-docker-registry/) a working example has been configured, but this in a way without https enabled which is not the recommended manner to set it up. Therefore we looked into enabling https instead. This can be done in different ways. 

#### SSL directly configured 

setting it up with https doesn't seemed straightforward with nexus directly connected. Also it has a disadvantage in the docker world that the certificates needs to be present on the container and some configuration changes needs to be made. This makes upgrading the nexus container on it's own a bit of a more complex task as without the direct SSL encryption enabled.

#### reverse proxy setup

we could instead spin up an nginx reverse proxy which will handle the encrypted requests towards the client. In the back it communicates to the nexus container service through plain HTTP on a dedicated docker network only for this kind of traffic.

Based on the standard setup for one private repository by [Stefan Prodan](https://stefanprodan.com/2016/docker-private-registry-nexus-nginx/)  I came to the described nginx configuration.

It will serve the web GUI when you access the proxy using a normal browser by a redirect to the nexus container on port 8081 where the management console is living. 

For the docker client it will act differently, when a docker pull command is executed it will get redirected to the docker-group repository which combines both images from upstream (cached) as well as images from the private docker repository.

On the other hand when issuing a docker push command the image will get pushed towards the private repository only since group and proxy repositories aren't able to do so.

```
worker_processes 2;

events {
        worker_connections 1024;
}

http {
        error_log /var/log/nginx/error.log warn;
        access_log /dev/null;
        proxy_intercept_errors off;
        proxy_send_timeout 120;
        proxy_read_timeout 300;

        upstream nexus-gui {
                server nexus:8081;
        }

        upstream docker-private {
                server nexus:5000;
        }
        upstream docker-group {
                server nexus:5001;
        }

        map $request_method $redirection {
                default "nexus-gui";
                "~GET" "docker-group";
                "~(HEAD|PATCH|PUT|POST|DELETE)" "docker-private";
        }

        server {
                listen 80;
                listen 443 ssl;
                server_name nexus.domain.org;
                ssl_certificate /etc/nginx/nginx.crt;
                ssl_certificate_key /etc/nginx/nginx.key;

                keepalive_timeout  5 5;
                proxy_buffering    off;

                # allow large uploads
                client_max_body_size 1G;

                location / {
                        if ($http_user_agent ~ docker ) {
                                proxy_pass http://$redirection;
                        }
                        proxy_pass http://nexus-gui;
                        proxy_set_header Host $host;
                        proxy_set_header X-Real-IP $remote_addr;
                        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                }
        }
}
```

Unfortunately when using a self signed key pair the client will not connect properly to the repository. You'll need to use [letsencrypt](https://letsencrypt.org) or another party to get a valid certificate from;

```
[root@dockernode ~]# docker login nexus.domain.org
Username: test
Password:
Error response from daemon: Get https://nexus.domain.org/v2/: x509: certificate signed by unknown authority
```
#### letsencrypt setup

when looking for solutions [letsencrypt](https://letsencrypt.org) could be an option in combination with an [nginx-proxy](https://github.com/jwilder/nginx-proxy) container. But for the moment we placed the auto nginx-proxy on a side track since only one service is needing the proxy and it can perfectly be combined with a docker-compose setup.

#### self signed certificates

in the meanwhile to gain some time we'll stick with the self generated scripts and use the insecure-registry workaround on the docker nodes, jenkins build servers and my local client. When heading for production we'll generate certificates with letsencrypt and I'll update this post.

##### centos 7 docker node daemon configuration
```
[root@dockernode ~]# vim /etc/systemd/system/docker.service.d/docker.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock --insecure-registry=nexus.domain.org

[root@dockernode ~]# systemctl daemon-reload
[root@dockernode ~]# systemctl restart docker.service
```

```
[root@dockernode ~]# docker login nexus.domain.org
Username: test
Password:
Login Succeeded
```

##### archlinux client configuration

```
$ sudo cat /etc/docker/daemon.json
{
  "insecure-registries" : ["nexus.domain.org"]
}

$ sudo systemctl restart docker.service
$ docker login nexus.domain.org
Username: test
Password:
Login Succeeded
```

## tips and tricks

### blobstore

we created a separate blob store for every repository, that way on the filesystem they are easily recognized for maintenance tasks in the future.

### removal

when removing a blob store and a repository through the GUI I noticed the actual content on the file system is still available, when recreating the repository and blob store with the same name the content is available again. When removing the content on the filesystem too you have again a clean repository to start with.

## future improvements and features

there are some features and configuration options that will need to be implemented in the future, when I got there I will update this blog post accordingly.
