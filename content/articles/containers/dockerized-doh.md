Title:       dockerized DNS over HTTPS using pi-hole through cloudflared proxy-dns
Author:      Jan
Date:        2018-04-21 21:00
Slug:        dockerized-cloudflared-pi-hole
Tags:        docker, compose, docker-compose, pi-hole, pihole, cloudflared, proxy-dns, DoH, dns, https, over
Status:      published
Modified:    2019-01-02

a few months ago I configured a thin client as my home server to replace the previous [raspberry pi](https://visibilityspots.org/raspberry-pi.html) setup.

During that migration I moved over all native services within docker containers. One of those services being a [pi-hole](https://pi-hole.net) setup to block ad serving domains on dns level and to have a dns cache within our LAN to gain a bit of speed.

It has been running ever since without any issue and worked pretty well.

When cloudflare [announced](https://blog.cloudflare.com/announcing-1111/) their fast and privacy based DNS resolver I got a bit intrigued by their DNS over HTTPS feature. Especially since our ISP telenet is using our [web history](http://www.forceflow.be/2016/09/14/aanpassingen-privacybeleid-telenet/) for their advertisements too.

So I stumbled on some articles from [Oliver Hough](https://oliverhough.cloud/blog/configure-pihole-with-dns-over-https/) and [Scott Helme](https://scotthelme.co.uk/securing-dns-across-all-of-my-devices-with-pihole-dns-over-https-1-1-1-1/) that describe how you can combine a [cloudflared proxy-dns](https://developers.cloudflare.com/1.1.1.1/dns-over-https/cloudflared-proxy/) with pi-hole to get your dns requests encrypted through HTTPS and still be able to filter out the advertisements.

Since I got everything in docker I configured a [cloudflared](https://hub.docker.com/r/visibilityspots/cloudflared/) container automated through [travis](https://travis-ci.org/visibilityspots/dockerfile-cloudflared) with [dgoss](https://github.com/aelsabbahy/goss/tree/master/extras/dgoss) tests.

I got some inspiration from [maartje](https://twitter.com/MaartjeME) who used a [matrix](https://github.com/meyskens/docker-cloudflared/blob/master/.travis.yml) to build multiple docker images for different architectures using travis. The main reason behind this was that after I got this setup up and running using this docker-compose file on my x86_64 machine I wanted to run it on a raspberry pi zero w.

For the pihole container I figured out you can easily pass by the custom DNS servers through docker environment variables so no need anymore for a custom pihole docker container to maintain!


```
$ cat docker-compose.yml
version: "3"

services:
  cloudflared:
    container_name: cloudflared
    image: visibilityspots/cloudflared:amd64
    restart: unless-stopped
    networks:
      pihole_net:
        ipv4_address: 10.0.0.2

  pi-hole:
    container_name: pi-hole
    image: pihole/pihole:v4.2.1_amd64
    restart: unless-stopped
    ports:
      - "80:80/tcp"
      - "53:53/tcp"
      - "53:53/udp"
    environment:
      - ServerIP=10.0.0.3
      - DNS1='10.0.0.2#5054'
      - DNS2=''
      - IPv6=false
      - TZ=CEST-2
      - DNSMASQ_LISTENING=all
      - WEBPASSWORD=admin
    networks:
      pihole_net:
        ipv4_address: 10.0.0.3
    dns:
      - 127.0.0.1
      - 1.1.1.1
    cap_add"
      - NET_ADMIN

networks:
  pihole_net:
    driver: bridge
    ipam:
     config:
       - subnet: 10.0.0.0/29
```

I remembered this [project](https://learn.adafruit.com/pi-hole-ad-blocker-with-pi-zero-w) where a raspberry pi zero W was used together with a tiny display. In the meanwhile I have the DoH cloudflared/pi-hole combination running on such a tiny device using [ArchLinux ARM](https://archlinuxarm.org) and ordered the display :D

You can use the same dockerfile on a raspberry pi zero but with other tags for the container images:

```
image: visibilityspots/cloudflared:arm
image: pihole/pihole:v4.0_armhf
```

As you can see unfortunately I had to configure static ip's since the dnsmasq config needs the ip address of the cloudflared service. If someone has a better solution to implement it let me know!

I also opted to not store the data. Meaning that when the docker containers are restarted the data is gone.

So when you now bring up those 2 containers:

```
$ docker-compose up -d
Creating network "###_pihole_net" with driver "bridge"
Creating pi-hole ...
Creating cloudflared ...
Creating pi-hole
Creating cloudflared ... done
```

```
$ docker-compose logs cloudflared
Attaching to cloudflared
cloudflared    | time="2018-04-16T20:01:14Z" level=info msg="Adding DNS upstream" url="https://1.1.1.1/.well-known/dns-query"
cloudflared    | time="2018-04-16T20:01:14Z" level=info msg="Adding DNS upstream" url="https://1.0.0.1/.well-known/dns-query"
cloudflared    | time="2018-04-16T20:01:14Z" level=info msg="Starting DNS over HTTPS proxy server" addr="dns://0.0.0.0:5054"
cloudflared    | time="2018-04-16T20:01:14Z" level=info msg="Starting metrics server" addr="127.0.0.1:35973"
```

```
$ docker-compose logs pi-hole
Attaching to pi-hole
...
pi-hole        | [services.d] starting services
pi-hole        | Starting lighttpd
pi-hole        | Starting dnsmasq
pi-hole        | Starting crond
pi-hole        | Starting pihole-FTL (no-daemon)
pi-hole        | [services.d] done.
pi-hole        | dnsmasq: started, version 2.76 cachesize 10000
pi-hole        | dnsmasq: compile time options: IPv6 GNU-getopt DBus i18n IDN DHCP DHCPv6 no-Lua TFTP conntrack ipset auth DNSSEC loop-detect inotify
pi-hole        | dnsmasq: using nameserver 10.0.0.2#5054
pi-hole        | dnsmasq: read /etc/hosts - 7 addresses
pi-hole        | dnsmasq: read /etc/pihole/local.list - 2 addresses
pi-hole        | dnsmasq: failed to load names from /etc/pihole/black.list: No such file or directory
pi-hole        | dnsmasq: read /etc/pihole/gravity.list - 121065 addresses
pi-hole        | dnsmasq: 1 127.0.0.1/48521 query[A] pi.hole from 127.0.0.1
pi-hole        | dnsmasq: 1 127.0.0.1/48521 /etc/pihole/local.list pi.hole is 10.0.0.3
```

you should be able to query the containerized pi-hole DNS service from it's host or from within your netwerk using dig:

```
$ dig @localhost -p 53 visibilityspots.org
($ dig @IP-ADDRESS-OF-DOCKER-NODE -p 53 visibilityspots.org)

; <<>> DiG 9.12.1 <<>> @localhost -p 53 visibilityspots.org
; (2 servers found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 51155
;; flags: qr rd ra; QUERY: 1, ANSWER: 8, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1536
;; QUESTION SECTION:
;visibilityspots.org.		IN	A

;; ANSWER SECTION:
visibilityspots.org.	37	IN	A	54.230.9.72
visibilityspots.org.	37	IN	A	54.230.9.109
visibilityspots.org.	37	IN	A	54.230.9.119
visibilityspots.org.	37	IN	A	54.230.9.143
visibilityspots.org.	37	IN	A	54.230.9.148
visibilityspots.org.	37	IN	A	54.230.9.182
visibilityspots.org.	37	IN	A	54.230.9.188
visibilityspots.org.	37	IN	A	54.230.9.203

;; Query time: 223 msec
;; SERVER: ::1#53(::1)
;; WHEN: Mon Apr 16 22:05:37 CEST 2018
;; MSG SIZE  rcvd: 328

```

Obviously I wanted to see myself that when sniffing the network the DNS requests aren't readable so I used tcp dump to prove myself the data was sent through HTTPS
```
pi-hole# tcpdump -i eth0 udp port 53
22:39:30.837594 IP 192.168.0.3.35765 > piholeContainerID.domain: 36972+ [1au] A? visibilityspots.com. (60)
22:39:31.009345 IP piholeContainerID.domain > 192.168.0.3.35765: 36972 8/0/1 A 54.230.228.38, A 54.230.228.42, A 54.230.228.54, A 54.230.228.68, A 54.230.228.69, A 54.230.228.84, A 54.230.228.92, A 54.230.228.104 (328)
```

```
cloudflared# tcpdump -i eth0 udp port 5054
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
20:39:29.029132 IP piholeContainerID.59189 > cloudflaredContainerID.5054: UDP, length 40
20:39:29.069864 IP cloudflaredContainerID.5054 > piholeContainerID.59189: UDP, length 116
20:39:30.838803 IP piholeContainerID.28892 > cloudflaredContainerID.5054: UDP, length 60
20:39:31.003756 IP cloudflaredContainerID.5054 > piholeContainerID.28892: UDP, length 328
20:39:31.352487 IP piholeContainerID.50291 > cloudflaredContainerID.5054: UDP, length 31
20:39:31.364073 IP piholeContainerID.16365 > cloudflaredContainerID.5054: UDP, length 31
20:39:31.411227 IP cloudflaredContainerID.5054 > piholeContainerID.50291: UDP, length 156
20:39:31.432364 IP cloudflaredContainerID.5054 > piholeContainerID.16365: UDP, length 218
```

So by now you can configure this new DNS service on your router or dhcp daemon within your local network.

Since the pi isn't running for a very long time I have no clue if it can cope with the load on our network but I'll keep you posted ;)
