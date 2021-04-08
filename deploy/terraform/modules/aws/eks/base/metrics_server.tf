data "template_file" "metrics_server_values" {
  template = file("${path.module}/templates/metrics-server-values.yml")
}

/*resource "helm_release" "metrics_server" {
  depends_on = [null_resource.cluster_blocker]

  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metrics-server"
  version    = "5.8.0"
  replace    = true

  values = [data.template_file.metrics_server_values.rendered]
}*/