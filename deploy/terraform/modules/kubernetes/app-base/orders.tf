resource "helm_release" "orders" {
  name       = "orders"
  chart      = "${local.src_dir}/orders/chart"
  namespace  = kubernetes_namespace.watchn.metadata[0].name

  set {
    name  = "mysql.create"
    value = var.orders_mysql_create
  }

  set {
    name  = "messaging.activemq.brokerUrl"
    value = var.orders_activemq_url
  }

  set {
    name  = "messaging.activemq.user"
    value = var.orders_activemq_user
  }

  set {
    name  = "messaging.activemq.password"
    value = var.orders_activemq_password
  }
}