locals {
  additional_dashboard_elements = var.cloudwatch_dashboard_elements == "" ? "" : ",${var.cloudwatch_dashboard_elements}"
}

resource "aws_cloudwatch_dashboard" "service" {
  dashboard_name = "${var.environment_name}-${var.service_name}"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_4XX_Count",
            "LoadBalancer",
            "${aws_alb.main.arn_suffix}"
          ],
          [
            ".",
            "HTTPCode_Target_3XX_Count",
            ".",
            "."
          ],
          [
            ".",
            "HTTPCode_Target_2XX_Count",
            ".",
            "."
          ],
          [
            ".",
            "HTTPCode_Target_5XX_Count",
            ".",
            "."
          ]
        ],
        "period": 60,
        "stat": "Sum",
        "region": "${var.region}",
        "title": "ALB Requests"
      }
    },
    {
      "type": "metric",
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "ECS/ContainerInsights", "PendingTaskCount", "ServiceName", "${aws_ecs_service.service.name}", "ClusterName", "${var.environment_name}" ],
          [ ".", "RunningTaskCount", ".", ".", ".", "." ],
          [ ".", "DesiredTaskCount", ".", ".", ".", "." ]
        ],
        "period": 60,
        "stat": "Sum",
        "region": "${var.region}",
        "title": "Tasks"
      }
    },
    {
      "type": "metric",
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/ECS", "CPUUtilization", "ServiceName", "${aws_ecs_service.service.name}", "ClusterName", "${var.environment_name}" ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "${var.region}",
        "title": "CPU Utilization"
      }
    },
    {
      "type": "metric",
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/ECS", "MemoryUtilization", "ServiceName", "${aws_ecs_service.service.name}", "ClusterName", "${var.environment_name}" ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "${var.region}",
        "title": "Memory Utilization"
      }
    }
    ${local.additional_dashboard_elements}
  ]
}
EOF
}