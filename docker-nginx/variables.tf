variable "external_port" {
  type    = list(number)
  default = [8081, 8082, 8083, 8084]
  validation {
    condition     = min(var.external_port...) > 0 && max(var.external_port...) < 65535
    error_message = "Ports are outside of range."
  }
}
variable "image" {
  type        = map(any)
  description = "Image selection depending on env."
  default = {
    "dev"  = "nginx:latest",
    "prod" = "nginx:stable"
  }
}