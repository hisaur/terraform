terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "docker" {
  host = "ssh://alex@127.0.0.1:22"
}
resource "docker_image" "nginx" {
  name = "nginx:latest"
}
resource "docker_container" "nginx" {
  count = 2
  image = docker_image.nginx.latest
  name  = join("-", ["nginx", random_string.nginx[count.index].result])
  ports {
    internal = 80
    external = random_integer.port_number[count.index].result
  }
}

resource "random_integer" "port_number" {
  count = 2
  min = 8080
  max = 8090
}
resource "random_string" "nginx" {
  count   = 2
  length  = 4
  special = false
  lower   = true
  upper   = false
}
output "Ports" {
  value = [for i in docker_container.nginx[*] : join(":",[i.ip_address],[i.ports[0].external])]
}
output "Containers_Names" {
  description = "nginx container names"
  value = join(", ",docker_container.nginx[*].name)
}