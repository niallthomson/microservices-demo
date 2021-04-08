resource "aws_ssm_parameter" "cwagent_config" {
  name  = "${local.full_environment_prefix}-cwagentconfig"
  type  = "String"
  tier  = "Advanced"
  value = <<CONTENT
{
  "logs": {
    "metrics_collected": {
      "prometheus": {
        "prometheus_config_path": "env:PROMETHEUS_CONFIG_CONTENT",
        "ecs_service_discovery": {
          "sd_frequency": "1m",
          "sd_result_file": "/tmp/cwagent_ecs_auto_sd.yaml",
          "docker_label": {
          },
          "task_definition_list": [
            {
              "sd_job_name": "watchn-ui",
              "sd_metrics_ports": "8080",
              "sd_task_definition_arn_pattern": ".*:task-definition/${local.full_environment_prefix}-ui:[0-9]+",
              "sd_metrics_path": "/actuator/prometheus"
            },
            {
              "sd_job_name": "watchn-catalog",
              "sd_metrics_ports": "8080",
              "sd_task_definition_arn_pattern": ".*:task-definition/${local.full_environment_prefix}-catalog:[0-9]+",
              "sd_metrics_path": "/metrics"
            },
            {
              "sd_job_name": "watchn-carts",
              "sd_metrics_ports": "8080",
              "sd_task_definition_arn_pattern": ".*:task-definition/${local.full_environment_prefix}-cart:[0-9]+",
              "sd_metrics_path": "/actuator/prometheus"
            },
            {
              "sd_job_name": "watchn-orders",
              "sd_metrics_ports": "8080",
              "sd_task_definition_arn_pattern": ".*:task-definition/${local.full_environment_prefix}-orders:[0-9]+",
              "sd_metrics_path": "/actuator/prometheus"
            }
          ]
        },
        "emf_processor": {
          "metric_declaration": [
            {
              "source_labels": ["container_name"],
              "label_matcher": "^envoy$",
              "dimensions": [["ClusterName","TaskDefinitionFamily"]],
              "metric_selectors": [
                "^envoy_http_downstream_rq_(total|xx)$",
                "^envoy_cluster_upstream_cx_(r|t)x_bytes_total$",
                "^envoy_cluster_membership_(healthy|total)$",
                "^envoy_server_memory_(allocated|heap_size)$",
                "^envoy_cluster_upstream_cx_(connect_timeout|destroy_local_with_active_rq)$",
                "^envoy_cluster_upstream_rq_(pending_failure_eject|pending_overflow|timeout|per_try_timeout|rx_reset|maintenance_mode)$",
                "^envoy_http_downstream_cx_destroy_remote_active_rq$",
                "^envoy_cluster_upstream_flow_control_(paused_reading_total|resumed_reading_total|backed_up_total|drained_total)$",
                "^envoy_cluster_upstream_rq_retry$",
                "^envoy_cluster_upstream_rq_retry_(success|overflow)$",
                "^envoy_server_(version|uptime|live)$"
              ]
            },
            {
              "source_labels": ["container_name"],
              "label_matcher": "^envoy$",
              "dimensions": [["ClusterName","TaskDefinitionFamily","envoy_http_conn_manager_prefix","envoy_response_code_class"]],
              "metric_selectors": [
                "^envoy_http_downstream_rq_xx$"
              ]
            },
            {
              "source_labels": ["platform"],
              "label_matcher": "java",
              "dimensions": [["ClusterName","TaskDefinitionFamily","status"]],
              "metric_selectors": [
                "http_server_requests_seconds_count"
              ]
            },
            {
              "source_labels": ["TaskDefinitionFamily"],
              "label_matcher": "${module.ui_service.service_name}",
              "dimensions": [["ClusterName","TaskDefinitionFamily","status","clientName"]],
              "metric_selectors": [
                "http_client_requests_seconds_(count|sum)"
              ]
            },
            {
              "source_labels": ["platform"],
              "label_matcher": "go",
              "dimensions": [["ClusterName","TaskDefinitionFamily"]],
              "metric_selectors": [
                "gin_request_duration_seconds_(sum|count)"
              ]
            },
            {
              "source_labels": ["platform"],
              "label_matcher": "go",
              "dimensions": [["ClusterName","TaskDefinitionFamily","db_name"]],
              "metric_selectors": [
                "go_sql_stats_connections_(blocked_seconds|closed_max_idle|closed_max_lifetime|idle|in_use|max_open|open|waited_for)"
              ]
            },
            {
              "source_labels": ["platform"],
              "label_matcher": "go",
              "dimensions": [["ClusterName","TaskDefinitionFamily","code"]],
              "metric_selectors": [
                "gin_requests_total"
              ]
            }
          ]
        }
      }
    },
    "force_flush_interval": 5
  }
}
CONTENT
}

resource "aws_ssm_parameter" "cwagent_prometheus_config" {
  name  = "${local.full_environment_prefix}-cwagent-prometheus-config"
  type  = "String"
  value = <<CONTENT
global:
  scrape_interval: 1m
  scrape_timeout: 10s
scrape_configs:
  - job_name: cwagent-ecs-file-sd-config
    sample_limit: 10000
    file_sd_configs:
      - files: [ "/tmp/cwagent_ecs_auto_sd.yaml" ]
CONTENT
}

resource "aws_ecs_task_definition" "cwagent" {
  family                   = "${local.full_environment_prefix}-cwagent"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.cwagent_execution_role.arn
  task_role_arn            = aws_iam_role.cwagent_task_role.arn

  cpu    = 512
  memory = 1024

  container_definitions = <<DEFINITION
[
  {
    "name": "cloudwatch-agent-prometheus",
    "image": "amazon/cloudwatch-agent:1.247347.3b250378",
    "cpu": 512,
    "memory": 1024,
    "essential": true,
    "secrets": [
      {
        "name": "PROMETHEUS_CONFIG_CONTENT",
        "valueFrom": "${aws_ssm_parameter.cwagent_prometheus_config.name}"
      },
      {
        "name": "CW_CONFIG_CONTENT",
        "valueFrom": "${aws_ssm_parameter.cwagent_config.name}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.cwagent_logs.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "dockerLabels": {
      "config_hash": "${base64sha256(aws_ssm_parameter.cwagent_config.value)}"
    }
  }
]
DEFINITION
}

resource "aws_ecs_service" "cwagent" {
  name                              = "${local.full_environment_prefix}-cwagent"
  cluster                           = module.cluster.cluster_id
  task_definition                   = aws_ecs_task_definition.cwagent.arn
  desired_count                     = 1
  platform_version                  = "1.4.0"

  network_configuration {
    security_groups = [module.cluster.task_security_group_id]
    subnets         = module.vpc.private_subnets
  }

  capacity_provider_strategy {
    capacity_provider  = "FARGATE"
    weight             = 1
  }
}

resource "aws_iam_role" "cwagent_task_role" {
  name = "${local.full_environment_prefix}-cwagent-task"
 
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

resource "aws_iam_role_policy_attachment" "cwagent_task_role_managed" {
  role       = aws_iam_role.cwagent_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
 
resource "aws_iam_role_policy_attachment" "cwagent_task_role_custom" {
  role       = aws_iam_role.cwagent_task_role.name
  policy_arn = aws_iam_policy.cwagent_task_role_policy.arn
}

resource "aws_iam_policy" "cwagent_task_role_policy" {
  name        = "${var.environment_name}-cwagent-task"
  path        = "/"
  description = "Cloudwatch policy for cwagent application"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllAPIActionsOnCart",
      "Effect": "Allow",
      "Action": [
        "ecs:DescribeTasks",
        "ecs:ListTasks",
        "ecs:DescribeContainerInstances",
        "ecs:DescribeServices",
        "ecs:ListServices",
        "ec2:DescribeInstances",
        "ecs:DescribeTaskDefinition"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "cwagent_execution_role" {
  name = "${local.full_environment_prefix}-cwagent-execution"
 
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

resource "aws_iam_role_policy_attachment" "cwagent_execution_role_cwmanaged" {
  role       = aws_iam_role.cwagent_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "cwagent_execution_role_ecsmanaged" {
  role       = aws_iam_role.cwagent_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "cwagent_execution_role_policy" {
  name = "${local.full_environment_prefix}-cwagent-execution"
  role = aws_iam_role.cwagent_execution_role.name

  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters"
      ],
      "Resource": [
        "${aws_ssm_parameter.cwagent_prometheus_config.arn}",
        "${aws_ssm_parameter.cwagent_config.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "cwagent_logs" {
  name              = "/watchn-ecs/${var.environment_name}/cwagent"
  retention_in_days = 7
}