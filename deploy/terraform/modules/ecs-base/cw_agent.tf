resource "aws_ssm_parameter" "cwagent_config" {
  name  = "${local.full_environment_prefix}-cwagentconfig"
  type  = "String"
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
              "source_labels": ["Java_EMF_Metrics"],
              "label_matcher": "^true$",
              "dimensions": [["ClusterName","TaskDefinitionFamily"]],
              "metric_selectors": [
                "^jvm_threads_(current|daemon)$",
                "^jvm_classes_loaded$",
                "^java_lang_operatingsystem_(freephysicalmemorysize|totalphysicalmemorysize|freeswapspacesize|totalswapspacesize|systemcpuload|processcpuload|availableprocessors|openfiledescriptorcount)$",
                "^catalina_manager_(rejectedsessions|activesessions)$",
                "^jvm_gc_collection_seconds_(count|sum)$",
                "^catalina_globalrequestprocessor_(bytesreceived|bytessent|requestcount|errorcount|processingtime)$"
              ]
            },
            {
              "source_labels": ["Java_EMF_Metrics"],
              "label_matcher": "^true$",
              "dimensions": [["ClusterName","TaskDefinitionFamily","area"]],
              "metric_selectors": [
                "^jvm_memory_bytes_used$"
              ]
            },
            {
              "source_labels": ["Java_EMF_Metrics"],
              "label_matcher": "^true$",
              "dimensions": [["ClusterName","TaskDefinitionFamily","pool"]],
              "metric_selectors": [
                "^jvm_memory_pool_bytes_used$"
              ]
            },
            {
              "source_labels": ["container_name"],
              "label_matcher": "application",
              "dimensions": [["ClusterName","TaskDefinitionFamily","status"]],
              "metric_selectors": [
                "http_server_requests_seconds_count"
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
        "awslogs-group": "${aws_cloudwatch_log_group.logs.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_service" "cwagent" {
  name                              = "${local.full_environment_prefix}-cwagent"
  cluster                           = aws_ecs_cluster.cluster.id
  task_definition                   = aws_ecs_task_definition.cwagent.arn
  desired_count                     = 1
  platform_version                  = "1.4.0"

  network_configuration {
    security_groups = [aws_security_group.nsg_task.id]
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
     "Effect": "Allow",
     "Sid": ""
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
 
resource "aws_iam_role_policy_attachment" "cwagent_execution_role_custom" {
  role       = aws_iam_role.cwagent_execution_role.name
  policy_arn = aws_iam_policy.cwagent_execution_role_policy.arn
}

resource "aws_iam_policy" "cwagent_execution_role_policy" {
  name        = "${var.environment_name}-cwagent-execution"
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
        "ssm:GetParameters"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}