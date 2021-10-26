data "template_file" "checkout_values" {
  template = file("${path.module}/templates/checkout-values.yaml")

  vars = {
    redis_create  = var.checkout_redis_create
    redis_address = var.checkout_redis_address
  }
}

resource "helm_release" "checkout" {
  name       = "checkout"
  chart      = "${local.src_dir}/checkout/chart"
  namespace  = kubernetes_namespace.watchn.metadata[0].name

  values = [data.template_file.checkout_values.rendered]
}