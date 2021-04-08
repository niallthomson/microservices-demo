module "app_service" {
  source = "../../app-service"

  environment_name          = var.environment_name
  service_name              = "checkout"
  region                    = var.region
  cluster_id                = var.cluster_id
  ecs_deployment_controller = var.ecs_deployment_controller
  vpc_id                    = var.vpc_id
  subnet_ids                = var.subnet_ids
  security_group_ids        = [ var.task_sg_id, aws_security_group.checkout.id ]
  lb_security_group_id      = var.lb_security_group_id
  sd_namespace_id           = var.sd_namespace_id
  cpu                       = 256
  memory                    = 512
  fargate                   = var.fargate
  ssm_kms_policy_arn        = var.ssm_kms_policy_arn
  docker_labels             = {
    "platform" = "node"
  }

  container_image           = "watchn/watchn-checkout:${var.image_tag}"
  environment               = [{
    name  = "REDIS_URL",
    value = "redis://${module.checkout_redis.address}:${module.checkout_redis.port}"
  },{
    name  = "REDIS_READER_URL",
    value = "redis://${module.checkout_redis.reader_address}:${module.checkout_redis.port}"
  },{
    name  = "ENDPOINTS_ORDERS",
    value = "http://${var.orders_dns}:8080"
  }]

  cloudwatch_dashboard_elements = module.checkout_redis.cloudwatch_dashboard_elements
}
resource "aws_security_group" "checkout" {
  name_prefix = "${var.environment_name}-checkout"
  vpc_id      = var.vpc_id

  description = "Marker SG for checkout service"
}

resource "aws_security_group_rule" "checkout_redis_ingress" {
  description = "Allow access from checkout ECS task"

  type                      = "ingress"
  from_port                 = module.checkout_redis.port
  to_port                   = module.checkout_redis.port
  protocol                  = "tcp"
  source_security_group_id  = aws_security_group.checkout.id
  security_group_id         = module.checkout_redis.security_group_id
}

module "checkout_redis" {
  source = "../../../elasticache-redis"

  environment_name   = var.environment_name
  instance_name      = "checkout"
  vpc_id             = var.vpc_id
  subnet_ids         = var.database_subnet_ids
  availability_zones = var.availability_zones
}