resource "aws_ecs_task_definition" "catalog" {
  family                   = "${local.full_environment_prefix}-catalog"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  cpu = 256
  memory = 512

  container_definitions    = <<DEFINITION
[
  {
    "name": "catalog",
    "image": "watchn/watchn-catalog:${var.image_tag}",
    "memory": 512,
    "essential": true,
    "environment": [
      {
        "name": "DB_ENDPOINT",
        "value": "${module.catalog_rds.writer_endpoint}"
      },
      {
        "name": "DB_USER",
        "value": "${module.catalog_rds.username}"
      },
      {
        "name": "DB_PASSWORD",
        "value": "${module.catalog_rds.password}"
      },
      {
        "name": "DB_READ_ENDPOINT",
        "value": "${module.catalog_rds.reader_endpoint}"
      },
      {
        "name": "DB_NAME",
        "value": "catalog"
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

resource "aws_ecs_service" "catalog" {
  name             = "${local.full_environment_prefix}-catalog"
  cluster          = aws_ecs_cluster.cluster.id
  task_definition  = aws_ecs_task_definition.catalog.arn
  desired_count    = 3
  platform_version = "1.4.0"

  network_configuration {
    security_groups = [aws_security_group.nsg_task.id, aws_security_group.catalog.id]
    subnets         = module.vpc.private_subnets
  }

  service_registries {
    registry_arn = aws_service_discovery_service.catalog.arn
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

resource "aws_security_group" "catalog" {
  name_prefix = "${local.full_environment_prefix}-catalog"
  vpc_id      = module.vpc.vpc_id

  description = "Marker SG for catalog service"
}

resource "aws_security_group_rule" "catalog_rds_ingress" {
  description = "From allowed CIDRs"

  type                      = "ingress"
  from_port                 = 3306
  to_port                   = 3306
  protocol                  = "tcp"
  source_security_group_id  = aws_security_group.catalog.id
  security_group_id         = module.catalog_rds.security_group_id
}

module "catalog_rds" {
  source = "../aws-global-rds-mysql"

  environment_name = local.full_environment_prefix
  instance_name    = "catalog"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.database_subnets
  db_name          = "catalog"
}

resource "aws_service_discovery_service" "catalog" {
  name  = "catalog"

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