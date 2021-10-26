data "template_file" "ui_values" {
  template = file("${path.module}/templates/ui-values.yaml")

  vars = {
    domain          = var.ui_domain
    ingress_enabled = !var.ui_istio_enabled
    istio_enabled   = var.ui_istio_enabled
  }
}

resource "helm_release" "ui" {
  name       = "ui"
  chart      = "${local.src_dir}/ui/chart"
  namespace  = kubernetes_namespace.watchn.metadata[0].name

  values = [data.template_file.ui_values.rendered]
}