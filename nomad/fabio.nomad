job "fabio" {
  datacenters = ["dc1"]
  type = "system"
  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "fabio" {
    task "fabio" {
      driver = "raw_exec"

      config {
        command = "fabio-1.5.13-go1.13.4-linux_amd64"
        args = ["-proxy.addr=:80", "-registry.consul.addr", "10.68.56.17:8500", "-ui.addr=:9998"]
      }

      artifact {
        source = "https://github.com/fabiolb/fabio/releases/download/v1.5.13/fabio-1.5.13-go1.13.4-linux_amd64"

        options {
          checksum = "md5:0EBFF3CA17D1D5A43FC39B72B6502B64"
        }
      }

      resources {
        cpu = 20
        memory = 64
        network {
          mbits = 1

          port "http" {
            static = 80
          }
          port "ui" {
            static = 9998
          }
        }
      }
    }
  }
}