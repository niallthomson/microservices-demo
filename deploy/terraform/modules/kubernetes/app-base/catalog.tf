resource "helm_release" "catalog" {
  name       = "catalog"
  chart      = "${local.src_dir}/catalog/chart"
  namespace  = kubernetes_namespace.watchn.metadata[0].name

  set {
    name  = "mysql.create"
    value = var.catalog_mysql_create
  }
}