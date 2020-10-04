resource "aws_service_discovery_private_dns_namespace" "sd" {
  name        = "watchn.local"
  description = "Service discovery namespace"
  vpc         = module.vpc.vpc_id
}

locals {
  store_dns = "store.${var.dns_suffix}"
}