provider "aws" {
  region = var.region
}

module "availability_zones" {
  source = "../modules/aws/az-util"

  region             = var.region
  availability_zones = var.availability_zones
}

module "eks_base" {
  source = "../modules/aws/eks/base"

  environment_name   = var.environment_name
  region             = var.region
  availability_zones = module.availability_zones.availability_zones
  dns_hosted_zone_id = data.aws_route53_zone.zone.id
  dns_base           = var.hosted_zone_name
  dns_prefix         = var.dns_prefix
  service_mesh       = var.service_mesh
  graviton2          = var.graviton2
}

data "aws_route53_zone" "zone" {
  name         = "${var.hosted_zone_name}."
  private_zone = false
}

resource "aws_route53_record" "app" {
  zone_id        = data.aws_route53_zone.zone.id
  name           = module.eks_base.store_dns_prefix
  type           = "A"
  ttl            = 30

  records        = module.eks_base.app_ingress_eips
}

resource "aws_route53_record" "monitoring" {
  zone_id        = data.aws_route53_zone.zone.id
  name           = "*.${module.eks_base.monitoring_dns_prefix}"
  type           = "A"
  ttl            = 30

  records        = module.eks_base.utility_ingress_eips
}