data "template_file" "metrics_server_values" {
  template = file("${path.module}/templates/metrics-server-values.yml")
}

resource "helm_release" "metrics_server" {
  depends_on = [null_resource.cluster_blocker]

  name      = "metrics-server"
  namespace = "kube-system"
  chart     = "stable/metrics-server"
  version   = "2.11.1"

  values = [data.template_file.metrics_server_values.rendered]
}