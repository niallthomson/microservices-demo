locals {
  istio_namespace = "istio-system"
  istio_enabled   = var.service_mesh == "istio" ? true : false
}

resource "aws_eip" "istio_ingress" {
  vpc   = true
  count = local.istio_enabled ? length(var.availability_zones) : 0
}

resource "kubernetes_namespace" "istio_system" {
  depends_on = [null_resource.cluster_blocker]

  count = local.istio_enabled ? 1 : 0

  metadata {
    name = local.istio_namespace
  }
}

data "template_file" "istio_yaml" {
  template = file("${path.module}/templates/istio.yml")

  vars = {
    eip_allocs   = join(",", aws_eip.istio_ingress.*.id)
    minReplicas = length(var.availability_zones)
  }
}

module "istio_apply" {
  depends_on = [kubernetes_namespace.istio_system]

  source = "../../../kubernetes/apply"

  name = "istio"
  blocker = null_resource.cluster_blocker.id
  yaml = data.template_file.istio_yaml.rendered
  run = local.istio_enabled
  sleep = 30
}