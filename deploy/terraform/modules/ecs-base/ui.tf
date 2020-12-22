resource "aws_ecs_task_definition" "ui" {
  family                   = "${local.full_environment_prefix}-ui"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  cpu = 256
  memory = 512

  container_definitions = <<DEFINITION
[
  {
    "name": "application",
    "image": "watchn/watchn-ui:${var.image_tag}",
    "memory": 512,
    "essential": true,
    "environment": [
      {
        "name": "ENDPOINTS_CATALOG",
        "value": "http://${module.catalog_service.sd_service_name}.${aws_service_discovery_private_dns_namespace.sd.name}:8080"
      },
      {
        "name": "ENDPOINTS_CARTS",
        "value": "http://${module.carts_service.sd_service_name}.${aws_service_discovery_private_dns_namespace.sd.name}:8080"
      },
      {
        "name": "ENDPOINTS_ORDERS",
        "value": "http://${module.orders_service.sd_service_name}.${aws_service_discovery_private_dns_namespace.sd.name}:8080"
      },
      {
        "name": "ENDPOINTS_CHECKOUT",
        "value": "http://${module.checkout_service.sd_service_name}.${aws_service_discovery_private_dns_namespace.sd.name}:8080"
      },
      {
        "name": "ENDPOINTS_ASSETS",
        "value": "http://${module.assets_service.sd_service_name}.${aws_service_discovery_private_dns_namespace.sd.name}:8080"
      },
      {
        "name": "JAVA_OPTS",
        "value": "-XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/urandom"
      }
    ],
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 8080
      }
    ],
    "readonlyRootFilesystem": true,
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

resource "aws_ecs_service" "ui" {
  name             = "${local.full_environment_prefix}-ui"
  cluster          = aws_ecs_cluster.cluster.id
  task_definition  = aws_ecs_task_definition.ui.arn
  desired_count    = 3
  platform_version = "1.4.0"

  network_configuration {
    security_groups = [aws_security_group.nsg_task.id, aws_security_group.ui.id]
    subnets         = module.vpc.private_subnets
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.id
    container_name   = "application"
    container_port   = 8080
  }

  health_check_grace_period_seconds = 60

  capacity_provider_strategy {
    capacity_provider  = "FARGATE"
    weight = 1
    base = 12
  }

  capacity_provider_strategy {
    capacity_provider  = "FARGATE_SPOT"
    weight = 0
  }

  # workaround for https://github.com/hashicorp/terraform/issues/12634
  depends_on = [aws_alb_listener.front_end]
}

resource "aws_security_group" "ui" {
  name_prefix = "${local.full_environment_prefix}-ui"
  vpc_id      = module.vpc.vpc_id

  description = "Marker SG for ui service"
}

resource "aws_security_group_rule" "allow_alb_in" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb_sg.id
  security_group_id        = aws_security_group.ui.id
}