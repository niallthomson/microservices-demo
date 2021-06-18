resource "aws_cloudwatch_metric_alarm" "latency" {
  alarm_name                = "${var.environment_name}-${var.component}-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "TargetResponseTime"
  namespace                 = "AWS/ApplicationELB"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "1000"
  alarm_description         = "This metric monitors Watchn ${var.component} service latency"
  insufficient_data_actions = []

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
}