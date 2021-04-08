module "cluster" {
  source = "../cluster"

  environment_name          = local.full_environment_prefix
  region                    = var.region
  availability_zones        = var.availability_zones
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnets
  graviton2                 = var.graviton2
  fargate                   = var.fargate
  ec2_instance_refresh      = var.ec2_instance_refresh
  ami_override_id           = var.ami_override_id
}