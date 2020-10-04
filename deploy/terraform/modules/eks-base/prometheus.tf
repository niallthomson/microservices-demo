resource "kubernetes_namespace" "prometheus" {
  depends_on = [null_resource.cluster_blocker]

  metadata {
    name = "prometheus"
  }
}

data "template_file" "prometheus_values" {
  template = file("${path.module}/templates/prometheus-values.yml")

  vars = {
    domain = "prometheus.${var.dns_suffix}"
  }
}

resource "helm_release" "prometheus" {
  name      = "prometheus"
  chart     = "stable/prometheus"
  namespace = kubernetes_namespace.prometheus.metadata[0].name

  values = [data.template_file.prometheus_values.rendered]
}

data "template_file" "prometheus_adapter_values" {
  template = file("${path.module}/templates/prometheus-adapter-values.yml")
}

resource "helm_release" "prometheus_adapter" {
  depends_on = [helm_release.prometheus]

  name      = "prometheus-adapter"
  chart     = "stable/prometheus-adapter"
  namespace = kubernetes_namespace.prometheus.metadata[0].name

  values = [data.template_file.prometheus_adapter_values.rendered]
}