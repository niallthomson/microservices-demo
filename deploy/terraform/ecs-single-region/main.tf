provider "aws" {
  region = var.region
}

module "availability_zones" {
  source = "../modules/aws/az-util"

  region             = var.region
  availability_zones = var.availability_zones
}

module "ecs_base" {
  source = "../modules/aws/ecs/base"

  environment_name     = var.environment_name
  region               = var.region
  availability_zones   = module.availability_zones.availability_zones
  dns_hosted_zone_id   = data.aws_route53_zone.zone.id
  dns_base             = var.hosted_zone_name
  dns_suffix           = "watchn.${var.hosted_zone_name}"
  fargate              = var.fargate
  graviton2            = var.graviton2
  ami_override_id      = var.ami_override_id
  use_cloud_map        = var.use_cloud_map
  ec2_instance_refresh = var.ec2_instance_refresh
}

data "aws_route53_zone" "zone" {
  name         = "${var.hosted_zone_name}."
  private_zone = false
}

resource "aws_route53_record" "app" {
  zone_id        = data.aws_route53_zone.zone.id
  name           = "store.watchn"
  type           = "A"
  
  alias {
    name                   = module.ecs_base.alb_dns_name
    zone_id                = module.ecs_base.alb_zone_id
    evaluate_target_health = true
  }
}