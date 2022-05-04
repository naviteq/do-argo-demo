terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.19.0"
    }
  }
}

provider "helm" {
  kubernetes {
    host             = data.digitalocean_kubernetes_cluster.demo.endpoint
    token            = data.digitalocean_kubernetes_cluster.demo.kube_config[0].token
    cluster_ca_certificate = base64decode(
      data.digitalocean_kubernetes_cluster.demo.kube_config[0].cluster_ca_certificate
    )
  }
}

provider "kubernetes" {
  host             = data.digitalocean_kubernetes_cluster.demo.endpoint
  token            = data.digitalocean_kubernetes_cluster.demo.kube_config[0].token
  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.demo.kube_config[0].cluster_ca_certificate
  )
}
