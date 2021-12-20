variable "image" {
  type        = map(any)
  description = "Image selection depending on env."
  default = {
    "dev"  = "nginx:latest",
    "prod" = "nginx:stable"
  }
}