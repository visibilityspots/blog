job "webserver" {
  datacenters = ["dc1"]
  type = "service"

  group "webserver" {

      network {
         port "webserver_web" {
           to = 80
         }
      }

     task "webserver" {
       driver = "docker"

      config {
        image = "httpd"
        force_pull = true
        ports = ["webserver_web"]
        logging {
          type = "journald"
          config {
            tag = "WEBSERVER"
          }
        }
      }

      service {
        name = "webserver"
      }
    }
  }
}

