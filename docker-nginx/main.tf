module "mkdir-script" {
  source   = "./mkdir-script"
  username = "alex"
  ssh_key  = file("C:/Users/Aleksandr_Toktosunov/.ssh/id_rsa")
  container_name = "nginx"
}
module "nginx" {
  source = "./container"
  image-in = docker_image.nginx.latest
  container_name = "nginx"
  external_port = [8080, 8081, 8082, 8083, 8084]
  container_count = 4
  depends_on = [
    module.mkdir-script
  ]
}
resource "docker_image" "nginx" {
  name = lookup(var.image, terraform.workspace)
}
###HELLO####
