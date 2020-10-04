resource "helm_release" "assets" {
  name       = "assets"
  chart      = "${path.module}/../../../../src/assets/chart"
  namespace  = kubernetes_namespace.watchn.metadata[0].name
}