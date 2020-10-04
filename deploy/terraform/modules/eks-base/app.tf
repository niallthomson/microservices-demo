module "app_base" {
  source = "../kubernetes-app-base"

  cluster_blocker = null_resource.cluster_blocker.id

  ui_domain = "store.${var.dns_suffix}"

  catalog_mysql_create = false

  carts_eks_service_account_arn = module.iam_assumable_role_admin.this_iam_role_arn
  carts_dynamodb_table_name = aws_dynamodb_table.carts[0].name
  carts_dynamodb_create = false

  orders_mysql_create = false
}