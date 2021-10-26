resource "helm_release" "carts" {
  name       = "carts"
  chart      = "${local.src_dir}/cart/chart"
  namespace  = kubernetes_namespace.watchn.metadata[0].name

  set {
    name  = "dynamodb.create"
    value = var.carts_dynamodb_create
  }

  set {
    name = "dynamodb.tableName"
    value = var.carts_dynamodb_table_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.carts_eks_service_account_arn
    type = "string"
  }
}