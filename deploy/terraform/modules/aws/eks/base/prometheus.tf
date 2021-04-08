resource "kubernetes_namespace" "prometheus" {
  depends_on = [null_resource.cluster_blocker]

  metadata {
    name = "prometheus"
  }
}

data "template_file" "prometheus_values" {
  template = file("${path.module}/templates/prometheus-values.yml")

  vars = {
    domain = local.prometheus_dns
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  chart      = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "13.6.0"
  namespace  = kubernetes_namespace.prometheus.metadata[0].name

  values = [data.template_file.prometheus_values.rendered]
}

data "template_file" "prometheus_adapter_values" {
  template = file("${path.module}/templates/prometheus-adapter-values.yml")
}

resource "helm_release" "prometheus_adapter" {
  depends_on = [helm_release.prometheus]

  name       = "prometheus-adapter"
  chart      = "prometheus-adapter"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "2.12.1"
  namespace  = kubernetes_namespace.prometheus.metadata[0].name
  replace    = true
  force_update = true

  values = [data.template_file.prometheus_adapter_values.rendered]
}