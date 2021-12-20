variable "image-in" {
  type = string 
}
variable "container_name" {
  type = string
}
variable "container_count" {
  type = number
  default = 1
}
variable "external_port" {
  type = list(number)
   validation {
    condition     = min(var.external_port...) > 0 && max(var.external_port...) < 65535
    error_message = "Ports are outside of range."
  }
}
variable "container_path" {
  type = string
  default = "/usr/share/nginx/html"
}