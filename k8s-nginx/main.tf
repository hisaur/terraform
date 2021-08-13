provider "kubernetes" {
  host        = "https://127.0.0.1:6443"
  config_path = "${path.module}/config"
  insecure    = true
}
resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx-terraform"
    namespace = kubernetes_namespace.nginx.metadata[0].name
    labels = {
      "app"     = "nginx"
      "creator" = "terraform"
    }
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        "app"     = "nginx"
        "creator" = "terraform"
      }
    }
    template {
      metadata {
        namespace = kubernetes_namespace.nginx.metadata[0].name
        labels = {
          "app"     = "nginx"
          "creator" = "terraform"
        }
        name = "nginx-terraform"
      }
      spec {
        container {
          name  = "nginx"
          image = "nginx"
        }
      }
    }
  }
}
resource "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.nginx.metadata[0].name
  }
  spec {
    selector = {
      "app"     = "nginx"
      "creator" = "terraform"
    }
    type = "NodePort"
    port {
      name        = "http"
      port        = 80
      target_port = 80
      node_port   = 30000
    }
  }
}
resource "kubernetes_namespace" "nginx" {
  metadata {
    name = "nginx"
    labels = {
      "app"     = "nginx"
      "creator" = "terraform"
    }
  }
}