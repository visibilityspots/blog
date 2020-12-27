Title:       Traefik nomad route53 setup
Author:      Jan
Date:        2020-12-27 21:00
Slug:        traefik-nomad-route53
Tags:        traefik, proxy, nomad, containers, route53
Modified:    2020-12-27
Status:      Published

I have this [nomad](https://nomadproject.io) cluster running on some spare devices for a while now. Serving my [plane spotting]({filename}/articles/other/planespotting.md) setup, [dns]({filename}dockerized-doh.md) setup, mqtt bridge and some other services I experiment with throughout the years. Until today I've always relied on the ip addresses to point my browser and other services towards the different services. For my DNS setup I even had to pin the jobs towards specific hardware using [meta](https://www.nomadproject.io/docs/configuration/client#custom-metadata-network-speed-and-node-class) data.

But I've always wanted to implement a proxy in between so I could rely on DNS names instead. This would also increase the flexibility of my DNS setup since for a couple of months now I figured the proxy I was looking into implemented UDP services too.

This proxy is [traefik](https://traefik.io/), a few years ago [Emile Vauge](https://twitter.com/emilevauge) talked about it on a meetup we organized with [Inuits](https://inuits.eu) in Prague. Ever since it stood on my todo list to get it implemented on my home lab.

But to be honest over the years traefik gained some interest and grew a lot. Which made it less attractive due to it's increased complexity compared to [fabio](https://fabiolb.net/) which works very well in combination with consul.

However by the time I had it up and running it lacked some letsencrypt integration as well as UDP ports and there where some doubts about it's [continuity](https://github.com/fabiolb/fabio/issues/735). Due the lack of time I never got it in the state I wanted it to be and the whole proxy plan got a bit dusted away.

This year I started to teach a group of students into linux using [nomad consul prometheus](https://github.com/visibilityspots/nomad-consul-prometheus) as a back bone. So my whole cluster gained some love again and I decided to upgrade it to the next level by implementing traefik!

So I started with a simple setup, a nomad traefik job which uses consul as service discovery and added some tags to the traefik job itself to gather the configuration to add itself to the proxy.
```
job "traefik" {

  region = "global"
  datacenters = ["DC1"]
  type = "service"

  group "traefik" {
    service {
      name = "traefik"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.dashboard.rule=Host(`traefik.example.org`)",
        "traefik.http.routers.dashboard.service=api@internal",
        "traefik.http.routers.dashboard.entrypoints=http",
      ]
    }

    task "traefik" {

      driver = "docker"

      config {
        image        = "traefik:v2.3.6"
        force_pull   = true
        network_mode = "host"
        logging {
          type = "journald"
          config {
            tag = "TRAEFIK"
          }
        }

        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml"
        ]
      }

      template {
        destination = "local/traefik.toml"
        data = <<EOF
[globals]
  sendAnonymousUsage = false
  checkNewVersion = false

[entryPoints]
  [entryPoints.http]
    address = ":80"

  [api]
    dashboard = true
    insecure = true

  [providers.file]
    filename = "/etc/traefik/traefik.toml"

  [providers.consulCatalog]
    prefix = "traefik"
    exposedByDefault = false

  [providers.consulCatalog.endpoint]
    address = "http://CONSUL-SERVER:8500"
    datacenter = "DC1"
EOF
      }
    }
  }
}
```

by starting this nomad job I got a first working dashboard after I configured traefik.example.org pointing towards the host where my traefik job was running upon in /etc/hosts.

As a second step I configured some middlewares. [BasicAuth](https://doc.traefik.io/traefik/middlewares/basicauth/) to enable authentication for several services so I could maybe expose them to others in the future. And some redirection for http towards https.

To achieve this I added an extra https entrypoint to the template and added the middleware as a tag to the traefik job;
```
[entryPoints]
  [entryPoints.http]
    address = ":80"
  [entryPoints.https]
    address = ":443"
```

```
group "traefik" {
    service {
      name = "traefik"

      tags = [
        "traefik.enable=true",
        "traefik.http.middlewares.http2https.redirectscheme.scheme=https",
```

As a start I configured every service separately to redirect its http traffic towards https. But I found out by reading through some issues in the community from an [answer](https://community.traefik.io/t/router-not-showing-up-using-consul-nomad/8770) by Kugel that this could also achieved by setting a global redirect;
```
group "traefik" {
    service {
      name = "traefik"

      tags = [
        ...
        "traefik.http.routers.catchall.rule=HostRegexp(`{host:(www\\.)?.+}`)",
        "traefik.http.routers.catchall.entrypoints=http",
        "traefik.http.routers.catchall.middlewares=http2https",
```

by issuing this catchall rule all the http incoming traffic will be redirected to their https service done in one place instead of a separate configuration for every service.

I gained some traction and configured letsencrypt, by default the letsencrypt certificateResolver uses the httpChallenge, but I didn't want to forward all http/https traffic from the internet towards my setup.

Also when you want to use a [wildcard](https://doc.traefik.io/traefik/https/acme/#wildcard-domains) certificate you'll have to use the [DNS-01](https://doc.traefik.io/traefik/https/acme/#dnschallenge) challenge. I looked into this wildcard domain since I hit the rate limitations quite fast. I asked certificates for every sub domain using my routers and forgot to mount the acme.json file. So I went to the internet, found a [solution](https://computerz.solutions/traefik-ssl-wildcard-letsencrypt/) for using a wildcard certificate for different services and fixed the acme.json mount.

Since I already got my domains configured in AWS I added a CNAME record for all my sub domains to point to the internal ip of the traefik instance which I pinned to a specific nomad client using metadata.

Luckily there is a [route53](https://doc.traefik.io/traefik/https/acme/#providers) provider, which only needs some [configuration](https://go-acme.github.io/lego/dns/route53/) in the AWS backend such as the IAM policy and a user from which you grab the ID's and keys to configure as environment variables towards the traefik container;
```
    task "traefik" {

      driver = "docker"

      env {
        AWS_ACCESS_KEY_ID = ""
        AWS_SECRET_ACCESS_KEY = ""
        AWS_HOSTED_ZONE_ID = ""
        AWS_REGION = "eu-west-1"
      }

```

Once the AWS part is done you can configure the certificateResolver part in the traefik.toml static configuration mark the commented caServer to use the staging environment of letsencrypt first before putting it into production to not hit the rate limit too soon ;);
```
[certificatesResolvers.letsencrypt.acme]
  email = "letsencrypt@example.org"
  storage = "/etc/traefik/acme/acme.json"
  #  caServer = "https://acme-staging-v02.api.letsencrypt.org/directory"
  [certificatesResolvers.letsencrypt.acme.dnsChallenge]
    provider = "route53"
    delaybeforecheck = "0"
```

and last but not least you'll have to reconfigure the traefik consul tags so the tls will be used;
```
  group "traefik" {
    service {
      name = "traefik"

      tags = [
        "traefik.http.routers.dashboard.rule=Host(`traefik.example.org`)",
        "traefik.http.routers.dashboard.service=api@internal",
        "traefik.http.routers.dashboard.entrypoints=https",
        "traefik.http.routers.dashboard.tls=true",
        "traefik.http.routers.dashboard.tls.certResolver=letsencrypt",
        "traefik.http.routers.dashboard.tls.domains[0].main=example.org",
        "traefik.http.routers.dashboard.tls.domains[0].sans=*.example.org"
      ]
```

Additional services on their turn can be configured in way they only have to enable tls and therefore falling back towards the wildcard certificate;
```
  group "helloworld" {
    service {
      name = "helloworld"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.helloworld-secure.rule=Host(`helloworld.example.org`)",
        "traefik.http.routers.helloworld-secure.entrypoints=https",
        "traefik.http.routers.helloworld-secure.tls=true",
        "traefik.http.routers.helloworld-secure.middlewares=default-auth"
      ]

```
So now letsencrypt only requests a wildcard for my domain with *.example.org as an alternative and all my services are using that wildcard. That way I could keep the letsencrypt communication to a bare minimum for my setup.

Next up was the long waiting UDP feature, therefor I had to configure a separate UDP [entrypoint](https://doc.traefik.io/traefik/routing/entrypoints/);
```
[entryPoints.dns]
  address = ":53/udp"
```

and a TCP [router](https://doc.traefik.io/traefik/routing/routers/#configuring-udp-routers) using tags in the [pihole]({filename}../containers/dockerized-doh.md) nomad job;
```
  group "pihole" {
    service {
      name = "pihole"

      tags = [
        "traefik.enable=true",
        "traefik.udp.routers.pihole-dns.entrypoints=dns"
      ]

```

That way I don't have to pin the pihole containers anymore to a specific node, traefik will proxy the DNS traffic towards the pihole service dynamically which is again a little step up in my humble home lab :)

And as finishing touch I also have configured the nomad service on every node with some [consul tags](https://www.nomadproject.io/docs/configuration/consul#tags) by doing so I'm able to configure a router using tags in the traefik job;
```
        "traefik.http.routers.nomad-ui.rule=Host(`nomad.example.org`)",
        "traefik.http.routers.nomad-ui.service=nomad-client@consulcatalog",
        "traefik.http.routers.nomad-ui.entrypoints=https",
        "traefik.http.routers.nomad-ui.tls=true"
```

nomad.example.org will now be redirected to the nomad dashboard through one of the different clients. Since it's a cluster I will always get the same state and don't have to bother which client to access :)

So I have now a nomad cluster running with containers I have absolutely no clue where they are running upon neither on which port they are listening. Traefik is the piece of software in between me using sub domains to access my services and the actual container running the software.

What I still need to look into is to use this proxy also to configure redirections towards static services like my synology and it's services as well as my router's interface etc. And I need to figure out how I could dynamically redirect consul.example.org towards the consul ui!
