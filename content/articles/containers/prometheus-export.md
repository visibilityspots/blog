Title:       Prometheus export/import
Author:      Jan
Date: 	     2018-06-06 22:00
Slug:	     prometheus-export-import
Tags: 	     prometheus, export, data, import, metrics, lock, waf, remote
Status:	     Published
Modified:    2018-06-11

bumping into the case where once deployed a full stack application we don't have any direct connection due to no uplink for security reasons.

So we (you too [@Tom](https://twitter.com/TomVanHumbeeck) looked into a way to export the prometheus data into a tar.gz which could be transferred and imported into an instance on our local machine.

After the initial blog post where we created a tar.gz file from the prometheus storage.tsdb.path on the filesystem [@roidelapluie](https://twitter.com/roidelapluie) pointed me out about the [snapshot](https://prometheus.io/docs/prometheus/latest/querying/api/#snapshot) feature.

So we did a bit of research and came up with this new procedure.

First of all make sure the prometheus service is running with the parameter **--web.enable-admin-api** which is disabled by default. For nomad I created a [job file](https://github.com/visibilityspots/nomad-consul-prometheus/blob/master/nomad/prometheus.hcl) which enables this parameter through the args for you.

Once you have the prometheus instance running with the admin api enabled you can use this api to create a snapshot:

```bash
$ curl -XPOST http://localhost:9090/api/v1/admin/tsdb/snapshot
{"status":"success","data":{"name":"20180611T130634Z-69ffcdcc60b89e54"}}
```

Next up is to collect the snapshot directory on your local machine and mount it into a fresh prometheus docker container for example.

```bash
($ docker container list)
(CONTAINER ID  IMAGE          COMMAND                  CREATED          STATUS          PORTS   NAMES)
(e19269f0c82c  cc866859f8df   "/bin/prometheus --c…"   45 minutes ago   Up 45 minutes           prometheus-eccbde40-c402-60cf-bee7-04a2e7e77883)
($ docker cp e19269f0c82c:/prometheus/snapshots /tmp/)

$ docker run --rm -p 9090:9090 -uroot -v /tmp/snapshots/20180611T130634Z-69ffcdcc60b89e54/:/prometheus prom/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/prometheus
```

When you now go to [http://localhost:9090](http://localhost:9090) you have the data available from the snapshot and you could start troubleshooting.

For example by starting a grafana container next to this prometheus container and configuring the prometheus one as data source.

That way you could create some dashboards for readability.

references:
- https://www.nomadproject.io/guides/nomad-metrics.html
- https://www.robustperception.io/taking-snapshots-of-prometheus-data/

