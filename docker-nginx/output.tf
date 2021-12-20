output "Container_Image" {
  description = "nginx container image"
  value       = lookup(var.image, terraform.workspace)
}
output "Container_Names" {
  description = "Container Names"
  value = module.nginx.Containers_Names
}
output "Container_Ports" {
  description = "Container Names"
  value = module.nginx.Ports
}