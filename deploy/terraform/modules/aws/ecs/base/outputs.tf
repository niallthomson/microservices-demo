output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns_name" {
  value = module.ui_service.alb_dns_name
}

output "alb_zone_id" {
  value = module.ui_service.alb_zone_id
}

output "store_dns" {
  value = local.store_dns
}

output "ecs_cluster_name" {
  value = module.cluster.cluster_name
}

output "ecs_service_names" {
  value = { 
    catalog  = module.catalog_service.service_name
    cart     = module.carts_service.service_name
    checkout = module.checkout_service.service_name
    orders   = module.orders_service.service_name
    assets   = module.assets_service.service_name
  }
}

output "alb_names" {
  value = { 
    catalog  = module.catalog_service.alb_name
    cart     = module.carts_service.alb_name
    checkout = module.checkout_service.alb_name
    orders   = module.orders_service.alb_name
    assets   = module.assets_service.alb_name
  }
}

output "alb_arn_suffixes" {
  value = { 
    catalog  = module.catalog_service.alb_arn_suffix
    cart     = module.carts_service.alb_arn_suffix
    checkout = module.checkout_service.alb_arn_suffix
    orders   = module.orders_service.alb_arn_suffix
    assets   = module.assets_service.alb_arn_suffix
  }
}

output "alb_listener_ids" {
  value = { 
    catalog  = module.catalog_service.alb_listener_id
    cart     = module.carts_service.alb_listener_id
    checkout = module.checkout_service.alb_listener_id
    orders   = module.orders_service.alb_listener_id
    assets   = module.assets_service.alb_listener_id
  }
}

output "alb_target_group_names" {
  value = { 
    catalog  = module.catalog_service.alb_target_group_name
    cart     = module.carts_service.alb_target_group_name
    checkout = module.checkout_service.alb_target_group_name
    orders   = module.orders_service.alb_target_group_name
    assets   = module.assets_service.alb_target_group_name
  }
}

output "health_checks" {
  value = { 
    catalog  = "/health"
    cart     = "/actuator/health"
    checkout = "/health"
    orders   = "/actuator/health"
    assets   = "/health.html"
  }
}