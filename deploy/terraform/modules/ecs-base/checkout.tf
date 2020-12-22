module "checkout_service" {
  source = "../ecs-app-service"

  environment_name          = local.full_environment_prefix
  service_name              = "checkout"
  cluster_id                = aws_ecs_cluster.cluster.id
  ecs_deployment_controller = var.ecs_deployment_controller
  execution_role_arn        = aws_iam_role.ecs_task_execution_role.arn
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnets
  security_group_id         = aws_security_group.nsg_task.id
  sd_namespace_id           = aws_service_discovery_private_dns_namespace.sd.id
  cpu                       = 256
  memory                    = 512

  container_definitions = <<DEFINITION
[
  {
    "name": "application",
    "image": "watchn/watchn-checkout:${var.image_tag}",
    "memory": 512,
    "essential": true,
    "environment": [
      {
        "name": "REDIS_URL",
        "value": "redis://${module.checkout_redis.address}:${module.checkout_redis.port}"
      }
    ],
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 8080
      }
    ],
    "healthcheck": {
      "command" : [ 
        "CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"
      ],
      "interval" : 30,
      "retries" : 3,
      "startPeriod" : 30,
      "timeout" : 10
    },
    "linuxParameters": {
      "capabilities": {
        "drop": ["ALL"]
      }
    },
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.logs.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
}

module "checkout_redis" {
  source = "../aws-elasticache-redis"

  environment_name = local.full_environment_prefix
  instance_name    = "checkout"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.database_subnets
}

resource "aws_security_group_rule" "checkout_redis_ingress" {
  description = "From allowed CIDRs"

  type                      = "ingress"
  from_port                 = module.checkout_redis.port
  to_port                   = module.checkout_redis.port
  protocol                  = "tcp"
  source_security_group_id  = module.checkout_service.security_group_id
  security_group_id         = module.checkout_redis.security_group_id
}