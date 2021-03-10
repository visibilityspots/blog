job "piaware" {
  region = "global"
  datacenters = ["visibilityspots"]
  type = "service"

  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "arm"
  }

  group "piaware" {
    count = 1

    restart {
      attempts = 3
      delay    = "60s"
      mode     = "delay"
    }

    update {
      max_parallel = 1
      health_check = "task_states"
      auto_revert  = true
    }

    task "piaware" {
      constraint {
        attribute = "${meta.purpose}"
        operator  = "="
        value     = "piaware"
      }

      driver = "docker"

      env {
        FEEDER_ID = ""
        TZ = "Europe/Brussels"
        LAT = ""
        LONG = ""
      }

      config {
        image = "mikenye/piaware:3.8.0-arm32v7"
        logging {
          type = "journald"
          config {
            tag = "PIAWARE"
          }
        }
        devices = [
          {
            host_path = "/dev/bus/usb/00#/00#
          }
        ]
      }

      service {
        name = "piaware"
        tags = [
          "piaware",
          "urlprefix-/piaware"
        ]
        port = "piaware_http"

        check {
          type = "http"
          port = "piaware_http"
          path = "/"
          interval = "10s"
          timeout = "2s"
        }
      }

      resources {
        memory = 250
        cpu = 2000

        network {
          port "piaware_http" { static = "8080" },
          port "piaware_beast" { static = "30005" }
        }
      }
    }

    task "fr24feed" {
      driver = "docker"

      env {
        TZ = "Europe/Brussels"
        BEASTHOST = "${NOMAD_IP_piaware_piaware_beast}"
        FR24KEY = ""
      }

      config {
        image = "mikenye/fr24feed:1.0.24-arm32v7"
        logging {
          type = "journald"
          config {
            tag = "FR24FEED"
          }
        }
      }

      service {
        name = "fr24feed"
        tags = [
          "fr24feed",
          "urlprefix-/fr24feed"
        ]
        port = "fr24feed_http"

        check {
          type = "http"
          port = "fr24feed_http"
          path = "/"
          interval = "10s"
          timeout = "2s"
        }
      }

      resources {
        memory = 250
        cpu = 1500

        network {
          port "fr24feed_http" { static = "8754" },
        }
      }
    }
  }
}
