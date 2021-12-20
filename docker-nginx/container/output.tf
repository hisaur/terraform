output "Ports" {
  value = [for i in docker_container.container[*] : join(":", [i.ip_address], [i.ports[0].external])]
}
output "Containers_Names" {
  description = "Container names"
  value       = join(", ", docker_container.container[*].name)
}