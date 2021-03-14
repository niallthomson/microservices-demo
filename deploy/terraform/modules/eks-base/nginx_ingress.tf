locals {
  nginx_ingress_enabled   = true
}

resource "aws_eip" "nginx_ingress" {
  vpc   = true
  count = local.nginx_ingress_enabled ? length(var.availability_zones) : 0
}

data "template_file" "nginx_config" {
  template = file("${path.module}/templates/nginx-ingress-values.yml")

  vars = {
    eip_allocs   = join(",", aws_eip.nginx_ingress.*.id)
    replicas     = length(var.availability_zones)
    minAvailable = length(var.availability_zones) > 1 ? length(var.availability_zones) - 1 : 1
    backendImage = var.graviton2 ? "k8s.gcr.io/defaultbackend-arm64" : "k8s.gcr.io/defaultbackend-amd64"
  }
}

resource "kubernetes_namespace" "nginx_ingress" {
  depends_on = [null_resource.cluster_blocker]
  count = local.nginx_ingress_enabled ? 1 : 0

  metadata {
    name = "nginx-ingress"
  }
}

resource "helm_release" "nginx_ingress" {
  depends_on = [kubernetes_namespace.nginx_ingress]
  count = local.nginx_ingress_enabled ? 1 : 0

  name      = "nginx-ingress"
  namespace = "nginx-ingress"
  chart     = "stable/nginx-ingress"
  version   = "1.41.3"

  values = [data.template_file.nginx_config.rendered]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}