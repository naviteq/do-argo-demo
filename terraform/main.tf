resource "digitalocean_kubernetes_cluster" "demo" {
  name   = "argo-demo"
  region = "fra1"
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.22.8-do.1"

  node_pool {
    name       = "service"
    size       = "s-2vcpu-2gb"
    node_count = 1
    labels = {
      purpose = "service"
    }
  }
}

resource "digitalocean_kubernetes_node_pool" "demo" {
  for_each = {
    application = {
      size       = "s-2vcpu-2gb"
      node_count = 1
      labels = {
        purpose = "application"
      }
    }
  }
  cluster_id = digitalocean_kubernetes_cluster.demo.id
  name       = each.key
  size       = each.value.size
  node_count = each.value.node_count
  labels = each.value.labels
}

resource "digitalocean_container_registry" "demo" {
  name                   = "naviteq-digitalocean-argo-demo"
  subscription_tier_slug = "basic"
}

resource "helm_release" "cluster-service" {
  for_each   = {
    cert-manager = {
      repository = "https://charts.jetstack.io"
      namespace = "nginx-ingress"
      version = "1.8.0"
    }
    ingress-nginx = {
      repository = "https://kubernetes.github.io/ingress-nginx"
      namespace = "cert-manager"
      version = "4.1.0"
    }
  }
  name       = each.key
  namespace  = each.value.namespace
  create_namespace = true
  repository = each.value.repository
  chart      = each.key
  version    = each.value.version
  values = [file("${path.module}/helm/${each.key}.yaml")]
}

resource "null_resource" "patch" {
  triggers = {
    config = local_file.kubeconfig.filename
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/k8s/ClusterIssuer.yaml"
    environment = {
      KUBECONFIG = local_file.kubeconfig.filename
    }
  }
  depends_on = [helm_release.cluster-service]
}

data "kubernetes_service" "nginx" {
  metadata {
    name = "${helm_release.cluster-service["ingress-nginx"].name}-controller"
    namespace = helm_release.cluster-service["ingress-nginx"].namespace
  }
}

resource "digitalocean_domain" "demo" {
  name = "argo-demo.naviteq.io"
  lifecycle {
    prevent_destroy = true
  }
}

resource "digitalocean_record" "www" {
  domain = digitalocean_domain.demo.id
  type   = "A"
  name   = "*"
  value  = data.kubernetes_service.nginx.status.0.load_balancer.0.ingress.0.ip
}
