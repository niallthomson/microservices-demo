resource "aws_codedeploy_app" "app" {
  compute_platform = "ECS"
  name             = "${var.environment_name}-${var.component}"
}

resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name               = aws_codedeploy_app.app.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "${var.environment_name}-${var.component}"
  service_role_arn       = var.codedeploy_role_arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.alb_listener_arn]
      }

      target_group {
        name = var.alb_target_group_name
      }

      target_group {
        name = aws_alb_target_group.target_group.name
      }
    }
  }

  alarm_configuration {
    alarms  = [aws_cloudwatch_metric_alarm.latency.alarm_name]
    enabled = true
  }
}

resource "aws_alb_target_group" "target_group" {
  name                 = "${var.environment_name}-${var.component}-green"
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 30
  target_type          = "ip"

  health_check {
    path                = var.healthcheck_path
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 20
    matcher             = "200-399"
  }
}