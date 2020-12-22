resource "aws_ecs_task_definition" "task" {
  family                   = "${var.environment_name}-${var.service_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  cpu    = var.cpu
  memory = var.memory

  container_definitions    = var.container_definitions
}

resource "aws_ecs_service" "service" {
  name             = "${var.environment_name}-${var.service_name}"
  cluster          = var.cluster_id
  task_definition  = aws_ecs_task_definition.task.arn
  desired_count    = 3
  platform_version = "1.4.0"

  lifecycle {
    ignore_changes = [
      task_definition,
      load_balancer,
      platform_version
    ]
  }

  network_configuration {
    security_groups = [var.security_group_id, aws_security_group.sg.id]
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