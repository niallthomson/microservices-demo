locals {
  carts_chaos_profile_map = {
    "" = []
    "errors" = ["chaos-monkey", "chaos-errors"]
    "latency" = ["chaos-monkey", "chaos-latency"]
  }
  carts_spring_profiles = ["dynamodb"]
}

module "carts_service" {
  source = "../ecs-app-service"

  environment_name          = local.full_environment_prefix
  service_name              = "cart"
  cluster_id                = aws_ecs_cluster.cluster.id
  ecs_deployment_controller = var.ecs_deployment_controller
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnets
  security_group_ids        = [ aws_security_group.nsg_task.id ]
  lb_security_group_id      = aws_security_group.lb_sg.id
  sd_namespace_id           = aws_service_discovery_private_dns_namespace.sd.id
  cpu                       = 512
  memory                    = 1024
  health_check_path         = "/actuator/health"
  health_check_grace_period = 120
  fargate                   = var.fargate
  ssm_kms_policy_arn        = aws_iam_policy.ssm_kms.arn

  container_definitions = <<DEFINITION
[
  {
    "name": "application",
    "image": "watchn/watchn-cart:${var.image_tag}",
    "memory": 1024,
    "cpu": 512,
    "essential": true,
    "environment": [
      {
        "name": "CARTS_DYNAMODB_TABLENAME",
        "value": "${aws_dynamodb_table.carts.name}"
      },
      {
        "name": "CARTS_DYNAMODB_CREATETABLE",
        "value": "false"
      },
      {
        "name": "SPRING_PROFILES_ACTIVE",
        "value": "${join(",", concat(local.carts_spring_profiles, local.carts_chaos_profile_map[var.carts_chaos]))}"
      },
      {
        "name": "JAVA_OPTS",
        "value": "-XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/urandom -XX:MaxMetaspaceSize=128m"
      }
    ],
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 8080
      }
    ],
    "healthcheck": {
      "command" : [ 
        "CMD-SHELL", "curl -f http://localhost:8080/actuator/health || exit 1"
      ],
      "interval" : 30,
      "retries" : 3,
      "startPeriod" : 60,
      "timeout" : 10
    },
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
 
resource "aws_iam_role_policy_attachment" "carts_role_attachment" {
  role       = module.carts_service.task_execution_role_name
  policy_arn = aws_iam_policy.carts_dynamo.arn
}