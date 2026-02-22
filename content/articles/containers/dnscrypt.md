Title:       DNS Crypt
Author:      Jan
Date:        2026-02-22 16:00
Slug:        dns-crypt
Tags:        docker, doh, container, dns, dnscrypt, crypt, blocky
Modified:    2026-02-22
Status:      published

A few years back I wrote a [blogpost](https://visibilityspots.org/dockerized-cloudflared-pi-hole.html) about how I combined a dockerized [cloudflared](https://github.com/visibilityspots/dockerfile-cloudflared) proxy-dns with pi-hole to get DNS over HTTPS up and running at home. The idea was simple: wrap the `cloudflared` binary into a lightweight docker image, wire it up with pi-hole, and have your DNS requests travel over HTTPS rather than plain UDP.

It was a modest little project. Nothing fancy — just packaging an existing binary, writing some [dgoss](https://github.com/aelsabbahy/goss/tree/master/extras/dgoss) tests around it, and automating the builds for multiple architectures through CI. But apparently it scratched an itch for a lot of people, because over the years the image accumulated **25,582,351 pulls** on [Docker Hub](https://hub.docker.com/r/visibilityspots/cloudflared). That number still surprises me every time I look at it.

## blocky

The setup didn't stay static. Over time I replaced pi-hole with [blocky](https://0xerr0r.github.io/blocky/) as my DNS resolver and ad blocker. Blocky felt more lightweight and config-file-driven which suits my workflow better — no web UI I'd rarely use, no database, just a clean YAML config checked into git.

The cloudflared container kept doing its job throughout all of that: sitting quietly upstream, forwarding DNS queries over HTTPS to Cloudflare's 1.1.1.1 resolver. It worked, and I didn't have to think about it much.

## end of an era

On November 11, 2025, Cloudflare [announced](https://developers.cloudflare.com/changelog/2025-11-11-cloudflared-proxy-dns/) that the `cloudflared proxy-dns` command — the exact command this entire docker image was built around — would be removed from all new `cloudflared` releases starting February 2, 2026.

The reason given was a security vulnerability in an underlying DNS library specific to the `proxy-dns` command. Cloudflare also acknowledged that `proxy-dns` had been an officially undocumented feature for several years, which explains why it quietly disappeared without much fanfare.

iExisting releases of `cloudflared` made before February 2, 2026 will still run the command, but Cloudflare only supports any given release for one year from its release date, so those will age out too. There's no point maintaining a docker image that wraps a command that no longer exists in current upstream releases.

Hence the dicision to archive my [dockerfile-cloudflared](https://github.com/visibilityspots/dockerfile-cloudflared/) github repository.

## dnscrypt

To replace cloudflared I switched to [DNSCrypt](https://www.dnscrypt.org/), a protocol that authenticates DNS traffic between your client and a resolver. [dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy) is the implementation I'm running, via the well-maintained [klutchell/dnscrypt-proxy-docker](https://github.com/klutchell/dnscrypt-proxy-docker) image rather than rolling my own.

DNSCrypt-proxy has a few things going for it that I appreciate:

- supports both DNSCrypt and DNS over HTTPS resolvers, giving you more flexibility in choosing upstream servers beyond just Cloudflare
- has built-in filtering, caching, and load balancing which reduces the need for a separate blocker depending on your use case
- the config file approach fits naturally alongside my blocky setup

The migration was straightforward. Swap out the cloudflared container, point blocky upstream at dnscrypt-proxy instead, done.

## closing out the repository

I've archived the [dockerfile-cloudflared](https://github.com/visibilityspots/dockerfile-cloudflared) repository. It'll stay up for reference — the image on Docker Hub isn't going anywhere either — but there won't be any new releases or maintenance from my side.

If you're still running this image and it works for you, it'll keep working. But if you're setting something up fresh, I'd suggest looking at the official `cloudflared` image maintained by Cloudflare themselves, or consider making the jump to dnscrypt-proxy like I did.

Looking back, the project taught me a lot beyond just packaging a binary. The CI/CD pipeline that grew around it over the years was probably where I learned the most. It started with Travis CI and eventually moved over to GitHub Actions, where I ended up with a set of workflows covering the full cycle.

Building and pushing multi-architecture images using `buildx`, running [dgoss](https://github.com/aelsabbahy/goss/tree/master/extras/dgoss) tests against the built image to verify it actually worked, keeping the Docker Hub description in sync automatically, and running [Trivy](https://github.com/aquasecurity/trivy) to scan for vulnerabilities on a schedule.

On top of that I started using [act](https://github.com/nektos/act) to run the GitHub Actions workflows locally before pushing, which saved a lot of noisy commits and made the feedback loop much tighter.

Small project, but it ended up being a pretty solid playground for learning how to wire all of this together.

Thanks to everyone who filed issues, sent PRs, or just used the thing. 25 million pulls for a wrapper image is not something I ever expected when I pushed the first version. It's been a good run.
