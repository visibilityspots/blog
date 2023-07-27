Title:       Nomad spread scheduler
Author:      Jan
Date:        2023-07-05 22:00
Slug:        nomad-spread-scheduler
Tags:        nomad, hashicorp, container, orchestration, spread, algorithm, scheduling
Status:      published
Modified:    2023-07-27

I'm maintaining a [nomad cluster](../nomad-arm-cluster.html) already a few years now at home, based on some thin clients and a few raspberry pi's.

The workload is growing from uses cases of the [plane-spotting](../planespotting.html) services towards a [pi-hole](../dockerized-cloudflared-pi-hole.html) setup, [vaultwarden](https://github.com/dani-garcia/vaultwarden), [homeassistant](https://www.home-assistant.io/) and many more use cases.

One of the issues I encountered was based on the default [scheduling algorithm](https://www.nomadproject.io/docs/concepts/scheduling/scheduling). Raspberry pi's are not known as the most efficient solution to run a huge workload. Default nomad will schedule new containers on one compute node until the resource limits of that node are consumed and only then will start consuming another node. This algorithm is named bin packing which is used to optimize resource utilization.

Although the idea seems leg-it I encountered a lot of issues due to this behavior where raspberry pi's got overloaded and therefor failing applications. From which one is the used DNS solution at home resulting in some mad family members not being able to surf anymore :D

Luckily there is an alternative algorithm available called the [spread algorithm](https://developer.hashicorp.com/nomad/docs/other-specifications/node-pool#scheduler_algorithm) which will spread your workload amongst the available nomad nodes.

First of all you can double check your current configuration by querying the nomad [operator API](https://developer.hashicorp.com/nomad/api-docs/operator/scheduler#sample-request)

You can also use the [operator API](https://developer.hashicorp.com/nomad/api-docs/operator/scheduler#update-scheduler-configuration) to update the scheduler configuration on the fly. But when you bootstrap a new node you need to configure it manually again for that particular node.

The service block also has an option to set a default scheduler;

```
$ cat /etc/nomad.d/nomad.hcl

server{
  default_scheduler_config {
    scheduler_algorithm = "spread"
  }
}
```

And of course restarting the nomad daemon.

Never since I encountered issues again by overloading one of the pi's and therefor resulting in failing applications on top of it.

An other approach would be to use the spread stanza in your nomad jobs, but this seemed to be a too much of a hassle for my home lab setup;

- [spreads-and-affinites-in-nomad](https://www.hashicorp.com/blog/spreads-and-affinites-in-nomad)
- [advanced-scheduling tutorial](https://developer.hashicorp.com/nomad/tutorials/advanced-scheduling/spread)
