Title:       Prometheus consul service discovery
Author:      Jan
Date: 	     2018-06-04 22:00
Slug:	     prometheus-consul
Tags: 	     prometheus, consul, service, discovery, dynamic, configuration
Status:	     published
Modified:    2018-06-04

as published a few months ago I worked out a [dockerized a jenkins farm](http://localhost:8000/jenkins-docker-pipeline.html) where both master as slaves are docker containers working together with services like nexus and such. Next to that setup I've dockerized my home setup where services like pi-hole, home-assistant and others are running as docker containers on a thin client I promoted to my home lab.

To have an overview about all those containers and the resources they are consuming I pulled in the git repo of [Brian Christner](https://github.com/vegasbrianc/prometheus) which spins up a whole [prometheus](https://prometheus.io) stack with some exporters and a grafana instance to visualize the different aspects of those containers.

The prometheus has been configured manually with hard coded endpoints to scrape in both situations. It works fine but somehow I would have liked prometheus to automatically recognizing the endpoints himself.

Luckily I bumped into [nomad](https://www.nomadproject.io) at my current project. Nomad is a tool for managing a cluster of machines and running applications on them  which uses [consul](https://www.consul.io/) as a key value store. And guess what, prometheus has an integration with consul!

Isn't that just great! By configuring prometheus to find it's endpoints in consul the only line of code is the one to point prometheus where he can find consul.

```
  - job_name: 'self'
    consul_sd_configs:
      - server: 'localhost:8500'
        services: []

```

But we went a bit further and used tags for that auto discovery. Prometheus will only fetch endpoints which are registered in consul with a certain tag. That way we hold some control in the configuration after all.

```
    relabel_configs:
      - source_labels: [__meta_consul_tags]
        regex: .*,metrics,.*
        action: keep
```

Another line is used to rename the endpoints in prometheus by a more human readable one instead of the auto generated one

```
      - source_labels: [__meta_consul_service]
        target_label: job
```

And that's about it. With this [prometheus.yml](https://github.com/visibilityspots/nomad-consul-prometheus/blob/master/prometheus/prometheus.yml) configuration file services started through nomad with the proper 'metrics' tag are auto discovered by prometheus as target.

To demonstrate this behavior I created a [github repository](https://github.com/visibilityspots/nomad-consul-prometheus) based on [vagrant](https://www.vagrantup.com) inspired by the [getting started](https://www.nomadproject.io/intro/getting-started/install.html) guide of nomad.

Following the [README](https://github.com/visibilityspots/nomad-consul-prometheus/blob/master/README.md) a prometheus consul stack is configured and running with 2 exporters you can automatically add to prometheus by starting them through nomad.

It's a pretty cool feeling when the appear and disappear without any manual configuration!

A great reference which cleared my mind during my quest on this topic came from [robust perception](https://www.robustperception.io/finding-consul-services-to-monitor-with-prometheus/)
