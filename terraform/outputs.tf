
resource "local_file" "kubeconfig" {
  content  = data.digitalocean_kubernetes_cluster.demo.kube_config.0.raw_config
  filename = "${path.module}/../kubeconfig.yaml"
  file_permission = "0600"
}

output "ns" {
  value = data.digitalocean_domain.demo.zone_file
}
