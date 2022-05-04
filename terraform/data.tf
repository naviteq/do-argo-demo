data "digitalocean_domain" "demo" {
  name = digitalocean_domain.demo.name
}

data "digitalocean_kubernetes_cluster" "demo" {
  name = digitalocean_kubernetes_cluster.demo.name
}
