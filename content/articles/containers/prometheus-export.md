Title:       Prometheus export/import
Author:      Jan
Date: 	     2018-06-06 22:00
Slug:	     prometheus-export-import
Tags: 	     prometheus, export, data, import, metrics, lock, waf, remote
Status:	     Published
Modified:    2018-06-06

bumping into the case where once deployed a full stack application we don't have any direct connection to due to no uplink for security reasons.

So we looked into a way to export the prometheus data into a tar.gz which could be transferred and imported into an instance on our local machine.

To export the data a tar.gz can be created from the configured storage.tsdb.path (default /prometheus) data directory.

(If you are running prometheus as a system service you can skip the first 2 docker related commands)

```bash
($ docker ps -a)
(CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS         NAMES)
(ab56eec3ebeb        cc866859f8df        "/bin/prometheus --c…"   2 hours ago         Up 2 hours                        prometheus)
($ docker exec -ti ab56eec3ebeb /bin/sh)

/prometheus $ ps -a
PID   USER     TIME   COMMAND
    1 root       0:00 /bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/prometheus --web.console.libraries=/usr/share/prometheus/console_libraries --web.console.templates=/usr/share/prometheus/consoles

/prometheus $ cd
~ $ tar --exclude lock -cvzf prometheus-data.tar.gz /prometheus/
```

Next up is to collect that tar.gz file on your local machine, extracting the prometheus data and mount it into a fresh prometheus docker container

```bash
($ docker cp ab56eec3ebeb:/home/prometheus-data.tar.gz .)

$ tar -xvzf prometheus-data.tar.gz
$ docker run -d --rm -p 9090:9090 --network host -uroot -v ${PWD}/prometheus:/prometheus prom/prometheus
```

When you now go to [http://localhost:9090](http://localhost:9090) you have the data available from the offsite instance and you could start troubleshooting.

For example by starting a grafana container next to this prometheus container and configuring the prometheus one as data source.

That way you could create some dashboards for readability.
