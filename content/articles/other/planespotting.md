Title:       Plane spotting on a nomad cluster
Author:      Jan
Date:        2020-03-31 21:00
Slug:        planespotting
Tags:        piaware, flightaware, dump1090, ADB-B, nomad, docker, flight, radar, 24, flightradar24, DVB-T, readsb, radarbox, planefinder, adsbexchange
Modified:    2020-03-31
Status:      published

Some weeks ago I upgraded my plane spotting setup by moving my antenna to the [roof]({filename}piaware.md). It was worth every single effort I've made into it. My stats are rocking ever since. Until the corona crisis halted almost every airline to standstill..

It gave me some time to thinker about my setup, and for some weird coincidence [Mike](https://github.com/mikenye) did create a series of docker containers like I was thinking about to implement. I have one pi connected to the USB device which captures the ADB radio signals.

But in the current situation it also feeds the flightaware service since I used the docker container for piaware. So I wanted to split those up.

And lucky for me Mike did some great work by creating a [readsb](https://github.com/mikenye/docker-readsb) container which only captures the signals and can be provides them to a port which can be easily consumed by services which feeds the positions towards a specific service.

Mike did a great effort on that part too and crafted several docker images which are able to consume an external beast host to provide the messages towards the services;

* [flightaware](https://github.com/mikenye/docker-piaware)
* [flightradar24](https://github.com/mikenye/docker-flightradar24)
* [adsbexchange](https://github.com/mikenye/docker-adsbexchange)
* [radarbox](https://github.com/mikenye/docker-radarbox)
* [planefinder](https://github.com/mikenye/docker-planefinder)


By doing so I could have the pi attached to the USB device dedicated for the readsb container and the other services are consuming other nodes in the nomad cluster to provide the leverage towards upstream. That way I have my setup spread over my whole [nomad](../nomad-arm-cluster.html) cluster.

Which makes it totally future proof and made my day during this lockdown.
