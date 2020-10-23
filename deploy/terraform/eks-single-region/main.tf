provider "aws" {
  region = var.region

  version = "~> 3.3.0"
}

module "availability_zones" {
  source = "../modules/aws-az-util"

  region             = var.region
  availability_zones = var.availability_zones
}

module "eks_base" {
  source = "../modules/eks-base"

  #environment_name   = var.environment_name
  region             = var.region
  availability_zones = module.availability_zones.availability_zones
  dns_hosted_zone_id = data.aws_route53_zone.zone.id
  dns_base           = var.hosted_zone_name
  dns_suffix         = "watchn.${var.hosted_zone_name}"
  service_mesh       = var.service_mesh
}

data "aws_route53_zone" "zone" {
  name         = "${var.hosted_zone_name}."
  private_zone = false
}

resource "aws_route53_record" "app" {
  zone_id        = data.aws_route53_zone.zone.id
  name           = "*.watchn"
  type           = "A"
  ttl            = 30

  records        = module.eks_base.nginx_ingress_eips
}