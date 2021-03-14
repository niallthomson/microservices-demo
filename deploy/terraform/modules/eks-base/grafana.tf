resource "kubernetes_namespace" "grafana" {
  depends_on = [null_resource.cluster_blocker]

  metadata {
    name = "grafana"
  }
}

data "template_file" "grafana_values" {
  template = file("${path.module}/templates/grafana-values.yml")

  vars = {
    domain = local.grafana_dns
  }
}

resource "helm_release" "grafana" {
  depends_on = [helm_release.prometheus]

  name       = "grafana"
  chart      = "grafana"
  version    = "6.6.2"
  repository = "https://grafana.github.io/helm-charts"
  namespace  = kubernetes_namespace.grafana.metadata[0].name
  replace    = true

  values = [data.template_file.grafana_values.rendered]
}