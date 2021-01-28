resource "aws_ecs_task_definition" "ui" {
  family                   = "${local.full_environment_prefix}-ui"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ui_role.arn

  cpu = 512
  memory = 1024

  container_definitions = <<DEFINITION
[
  {
    "name": "application",
    "image": "watchn/watchn-ui:cloudwatch1",
    "cpu": 512,
    "memory": 1024,
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
    "healthCheck": {
      "command" : [ 
        "CMD-SHELL", "curl -f http://localhost:8080/actuator/health || exit 1"
      ],
      "interval" : 30,
      "retries" : 3,
      "startPeriod" : 60,
      "timeout" : 10
    },
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
  name                              = "${local.full_environment_prefix}-ui"
  cluster                           = aws_ecs_cluster.cluster.id
  task_definition                   = aws_ecs_task_definition.ui.arn
  desired_count                     = 3
  platform_version                  = "1.4.0"

  network_configuration {
    security_groups = [aws_security_group.nsg_task.id, aws_security_group.ui.id]
    subnets         = module.vpc.private_subnets
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
    base = 3
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
  name_prefix = "${local.full_environment_prefix}-ui"
  vpc_id      = module.vpc.vpc_id

  description = "Marker SG for ui service"
}

resource "aws_iam_role" "ui_role" {
  name = "${local.full_environment_prefix}-ui"
 
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
 
resource "aws_iam_role_policy_attachment" "ui_role_attachment" {
  role       = aws_iam_role.ui_role.name
  policy_arn = aws_iam_policy.ui_cloudwatch.arn
}

resource "aws_iam_policy" "ui_cloudwatch" {
  name        = "${var.environment_name}-ui-cloudwatch"
  path        = "/"
  description = "Cloudwatch policy for ui application"

  policy = <<EOF
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
  min_capacity       = 3
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.ui.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ui_policy" {
  name               = "${local.full_environment_prefix}-ui"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ui_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ui_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ui_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_alb.main.arn_suffix}/${aws_alb_target_group.main.arn_suffix}"
    }

    target_value       = 50
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}