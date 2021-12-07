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
resource "null_resource" "script" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = "127.0.0.1"
      user        = "alex"
      private_key = file("C:/Users/Aleksandr_Toktosunov/.ssh/id_rsa")
      timeout     = "30s"
    }
    inline = [
      "sudo mkdir /tmp/nginx 2> /dev/null; ",
      "sudo echo \\<Html\\>\\<title\\>Sample Nginx Web Page\\</title\\>\\<b\\>Hello World\\</b\\>\\<\\i\\>\\Hello World\\</i\\>\\<u\\> Hello World\\</u\\>\\</Html\\> | sudo tee /tmp/nginx/index.html 1> /dev/null;",
      "sudo chown -R 1000:1000 /tmp/nginx; exit 0"
    ]
  }
}
resource "docker_image" "nginx" {
  name = lookup(var.image, terraform.workspace)
}
resource "docker_container" "nginx" {
  count = 4
  image = docker_image.nginx.latest
  name  = join("-", ["nginx", terraform.workspace, random_string.nginx[count.index].result])
  depends_on = [
    null_resource.script
  ]
  ports {
    internal = 80
    external = var.external_port[count.index]
  }
  volumes {
    container_path = "/usr/share/nginx/html"
    host_path      = "/tmp/nginx"
  }
}

/*
Block for import
resource "docker_container" "nginx2" {
  image = docker_image.nginx.latest
  name = "nginx-3l2t"
}
*/
resource "random_integer" "port_number" {
  count = 4
  min   = 8080
  max   = 8090
}
resource "random_string" "nginx" {
  count   = 4
  length  = 4
  special = false
  lower   = true
  upper   = false
}
output "Ports" {
  value = [for i in docker_container.nginx[*] : join(":", [i.ip_address], [i.ports[0].external])]
}
output "Containers_Names" {
  description = "nginx container names"
  value       = join(", ", docker_container.nginx[*].name)
}
output "Container_Image" {
  description = "nginx container image"
  value       = lookup(var.image, terraform.workspace)

}