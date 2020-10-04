data "template_file" "ui_values" {
  template = file("${path.module}/templates/ui-values.yaml")

  vars = {
    domain = var.ui_domain
  }
}

resource "helm_release" "ui" {
  name       = "ui"
  chart      = "${path.module}/../../../../src/ui/chart"
  namespace  = kubernetes_namespace.watchn.metadata[0].name

  values = [data.template_file.ui_values.rendered]
}