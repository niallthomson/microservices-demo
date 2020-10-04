resource "helm_release" "orders" {
  name       = "orders"
  chart      = "${path.module}/../../../../src/orders/chart"
  namespace  = kubernetes_namespace.watchn.metadata[0].name

  set {
    name  = "mysql.create"
    value = var.orders_mysql_create
  }
}