resource "aws_ecs_task_definition" "ui" {
  family                   = "${var.environment_name}-ui"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ui_execution_role.arn
  task_role_arn            = aws_iam_role.ui_role.arn

  cpu    = 512
  memory = 1024

  container_definitions = <<DEFINITION
[
  {
    "name": "application",
    "image": "watchn/watchn-ui:${var.image_tag}",
    "cpu": 512,
    "memory": 1024,
    "essential": true,
    "environment": [
      {
        "name": "ENDPOINTS_CATALOG",
        "value": "http://${var.catalog_dns}:8080"
      },
      {
        "name": "ENDPOINTS_CARTS",
        "value": "http://${var.carts_dns}:8080"
      },
      {
        "name": "ENDPOINTS_ORDERS",
        "value": "http://${var.orders_dns}:8080"
      },
      {
        "name": "ENDPOINTS_CHECKOUT",
        "value": "http://${var.checkout_dns}:8080"
      },
      {
        "name": "ENDPOINTS_ASSETS",
        "value": "http://${var.assets_dns}:8080"
      },
      {
        "name": "SPRING_PROFILES_ACTIVE",
        "value": "prod"
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
        "awslogs-group": "${aws_cloudwatch_log_group.ui_logs.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "dockerLabels": {
      "platform": "java"
    }
  }
]
DEFINITION
}

resource "aws_ecs_service" "ui" {
  name                              = "${var.environment_name}-ui"
  cluster                           = var.cluster_id
  task_definition                   = aws_ecs_task_definition.ui.arn
  desired_count                     = length(var.subnet_ids)
  platform_version                  = "1.4.0"

  network_configuration {
    security_groups = [var.task_sg_id, aws_security_group.ui.id]
    subnets         = var.subnet_ids
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.id
    container_name   = "application"
    container_port   = 8080
  }

  health_check_grace_period_seconds = 120

  capacity_provider_strategy {
    capacity_provider  = "FARGATE"
    weight = 0
    base = length(var.subnet_ids)
  }

  capacity_provider_strategy {
    capacity_provider  = "FARGATE_SPOT"
    weight = 1
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  # workaround for https://github.com/hashicorp/terraform/issues/12634
  depends_on = [aws_alb_listener.front_end]
}

resource "aws_security_group" "ui" {
  name_prefix = "${var.environment_name}-ui"
  vpc_id      = var.vpc_id

  description = "Marker SG for ui service"
}

resource "aws_iam_role" "ui_role" {
  name = "${var.environment_name}-ui"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy" "ui_role" {
  name = "${var.environment_name}-ui"
  role = aws_iam_role.ui_role.name

  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricData"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_appautoscaling_target" "ui_target" {
  max_capacity       = 9
  min_capacity       = length(var.subnet_ids)
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.ui.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ui_policy" {
  name               = "${var.environment_name}-ui"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ui_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ui_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ui_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_alb.main.arn_suffix}/${aws_alb_target_group.main.arn_suffix}"
    }

    target_value       = 400
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_cloudwatch_log_group" "ui_logs" {
  name              = "/watchn-ecs/${var.environment_name}/ui"
  retention_in_days = 7
}

resource "aws_iam_role" "ui_execution_role" {
  name               = "${var.environment_name}-ui-execution"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ui_execution_managed_policy" {
  role       = aws_iam_role.ui_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ui_execution_ssm_kms_policy" {
  role       = aws_iam_role.ui_execution_role.name
  policy_arn = var.ssm_kms_policy_arn
}