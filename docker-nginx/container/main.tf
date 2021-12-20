resource "random_string" "container-random-string" {
  count   = var.container_count
  length  = 4
  special = false
  lower   = true
  upper   = false
}
resource "docker_container" "container" {
  count = var.container_count
  image = var.image-in
  name  = join("-", [var.container_name, terraform.workspace, random_string.container-random-string[count.index].result])
  ports {
    internal = 80
    external = var.external_port[count.index]
  }
  volumes {
    container_path = var.container_path
    host_path      = join("",["/tmp/",var.container_name])
  }
}
