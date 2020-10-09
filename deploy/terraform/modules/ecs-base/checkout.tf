resource "aws_ecs_task_definition" "checkout" {
  family                   = "${local.full_environment_prefix}-checkout"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  cpu = 256
  memory = 512

  container_definitions    = <<DEFINITION
[
  {
    "name": "checkout",
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

resource "aws_ecs_service" "checkout" {
  name             = "${local.full_environment_prefix}-checkout"
  cluster          = aws_ecs_cluster.cluster.id
  task_definition  = aws_ecs_task_definition.checkout.arn
  desired_count    = 3
  platform_version = "1.4.0"

  network_configuration {
    security_groups = [aws_security_group.nsg_task.id, aws_security_group.checkout.id]
    subnets         = module.vpc.private_subnets
  }

  service_registries {
    registry_arn = aws_service_discovery_service.checkout.arn
  }

  capacity_provider_strategy {
    capacity_provider  = "FARGATE"
    weight = 1
    base = 3
  }

  capacity_provider_strategy {
    capacity_provider  = "FARGATE_SPOT"
    weight = 4
  }
}

resource "aws_security_group" "checkout" {
  name_prefix = "${local.full_environment_prefix}-checkout"
  vpc_id      = module.vpc.vpc_id

  description = "Marker SG for checkout service"
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
  source_security_group_id  = aws_security_group.checkout.id
  security_group_id         = module.checkout_redis.security_group_id
}

resource "aws_service_discovery_service" "checkout" {
  name  = "checkout"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.sd.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}