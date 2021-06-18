locals {
  linuxParameters = !var.drop_capabilities ? "" : <<CONTENT
"linuxParameters": {
  "capabilities": {
    "drop": ["ALL"]
  },
  "tmpfs": [{
    "containerPath": "/tmp",
    "size": 64
  }]
},
CONTENT
}

resource "aws_ecs_task_definition" "task" {
  family                   = "${var.environment_name}-${var.service_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = var.fargate ? ["FARGATE"] : []
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = var.cpu
  memory                   = var.memory

  container_definitions = <<DEFINITION
[
  {
    "name": "application",
    "image": "${var.container_image}",
    "cpu": ${var.cpu},
    "memory": ${var.memory},
    "essential": true,
    "environment": ${jsonencode(var.environment)},
    "secrets": ${jsonencode(var.secrets)},
    "portMappings": [{
      "protocol": "tcp",
      "containerPort": 8080
    }],
    "readonlyRootFilesystem": ${var.readonly_filesystem},
    ${local.linuxParameters}
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.logs.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "dockerLabels": ${jsonencode(var.docker_labels)}
  }
]
DEFINITION
}

resource "aws_ecs_service" "service" {
  name                              = "${var.environment_name}-${var.service_name}"
  cluster                           = var.cluster_id
  task_definition                   = aws_ecs_task_definition.task.arn
  desired_count                     = length(var.subnet_ids)
  platform_version                  = var.fargate ? "1.4.0" : null
  health_check_grace_period_seconds = var.health_check_grace_period

  lifecycle {
    ignore_changes = [
      load_balancer,
      platform_version,
      capacity_provider_strategy
    ]
  }

  network_configuration {
    security_groups = var.security_group_ids
    subnets         = var.subnet_ids
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.id
    container_name   = "application"
    container_port   = 8080
  }

  deployment_controller {
    type = var.ecs_deployment_controller
  }

  service_registries {
    registry_arn = aws_service_discovery_service.sd.arn
  }
}