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
  image = docker_image.nginx.latest
  name  = "nginx"
  ports {
    internal = 80
    external = 8080
  }
}