resource "helm_release" "assets" {
  name       = "assets"
  chart      = "${local.src_dir}/assets/chart"
  namespace  = kubernetes_namespace.watchn.metadata[0].name
}