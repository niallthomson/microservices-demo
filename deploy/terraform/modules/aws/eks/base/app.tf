resource "null_resource" "app_blocker" {
  depends_on = [module.istio_apply]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

module "app_base" {
  source = "../../../kubernetes/app-base"

  cluster_blocker = null_resource.app_blocker.id

  ui_domain        = local.store_dns
  ui_istio_enabled = var.service_mesh == "istio"

  catalog_mysql_create = false

  carts_eks_service_account_arn = module.iam_assumable_role_admin.this_iam_role_arn
  carts_dynamodb_table_name     = aws_dynamodb_table.carts[0].name
  carts_dynamodb_create         = false

  orders_mysql_create      = false
  orders_activemq_url      = module.mq.wire_endpoint
  orders_activemq_user     = module.mq.user
  orders_activemq_password = module.mq.password

  checkout_redis_create  = false
  checkout_redis_address = module.checkout_redis.address
}