locals {
  catalog_dns  = var.use_cloud_map ? "${module.catalog_service.sd_service_name}.${aws_service_discovery_private_dns_namespace.sd.name}" : module.catalog_service.alb_dns
  checkout_dns = var.use_cloud_map ? "${module.checkout_service.sd_service_name}.${aws_service_discovery_private_dns_namespace.sd.name}" : module.checkout_service.alb_dns
  carts_dns    = var.use_cloud_map ? "${module.carts_service.sd_service_name}.${aws_service_discovery_private_dns_namespace.sd.name}" : module.carts_service.alb_dns
  orders_dns   = var.use_cloud_map ? "${module.orders_service.sd_service_name}.${aws_service_discovery_private_dns_namespace.sd.name}" : module.orders_service.alb_dns
  assets_dns  = var.use_cloud_map ? "${module.assets_service.sd_service_name}.${aws_service_discovery_private_dns_namespace.sd.name}" : module.assets_service.alb_dns
}

module "ui_service" {
  source = "../services/ui"

  environment_name          = local.full_environment_prefix
  region                    = var.region
  cluster_id                = module.cluster.cluster_id
  cluster_name              = module.cluster.cluster_name
  image_tag                 = module.image_tag.image_tag
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnets
  public_subnet_ids         = module.vpc.public_subnets
  task_sg_id                = module.cluster.task_security_group_id
  lb_security_group_id      = module.cluster.lb_security_group_id
  ssm_kms_policy_arn        = aws_iam_policy.ssm_kms.arn
  dns_hosted_zone_id        = var.dns_hosted_zone_id
  store_dns                 = local.store_dns

  catalog_dns  = local.catalog_dns
  carts_dns    = local.carts_dns
  checkout_dns = local.checkout_dns
  orders_dns   = local.orders_dns
  assets_dns   = local.assets_dns
}