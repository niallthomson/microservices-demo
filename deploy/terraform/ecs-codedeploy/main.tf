provider "aws" {
  region = var.region

  version = "~> 3.3.0"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

module "availability_zones" {
  source = "../modules/aws-az-util"

  region             = var.region
  availability_zones = var.availability_zones
}

module "ecs_base" {
  source = "../modules/ecs-base"

  environment_name          = var.environment_name
  region                    = var.region
  availability_zones        = module.availability_zones.availability_zones
  dns_hosted_zone_id        = data.aws_route53_zone.zone.id
  dns_base                  = var.hosted_zone_name
  dns_suffix                = "watchn.${var.hosted_zone_name}"
  ecs_deployment_controller = "CODE_DEPLOY"
  carts_chaos               = var.carts_chaos
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