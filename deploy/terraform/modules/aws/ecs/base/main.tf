locals {
  full_environment_prefix = var.environment_name
}

data "aws_caller_identity" "current" {}

module "image_tag" {
  source = "../../../image-tag"
}