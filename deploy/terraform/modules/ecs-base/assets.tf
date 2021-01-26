module "assets_service" {
  source = "../ecs-app-service"

  environment_name          = local.full_environment_prefix
  service_name              = "assets"
  cluster_id                = aws_ecs_cluster.cluster.id
  ecs_deployment_controller = var.ecs_deployment_controller
  execution_role_arn        = aws_iam_role.ecs_task_execution_role.arn
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnets
  security_group_id         = aws_security_group.nsg_task.id
  sd_namespace_id           = aws_service_discovery_private_dns_namespace.sd.id
  cpu                       = 256
  memory                    = 512
  health_check_path         = "/health.html"
  capacity_provider_ec2     = aws_ecs_capacity_provider.asg_ondemand.name
  fargate                   = var.fargate

  container_definitions = <<DEFINITION
[
  {
    "name": "application",
    "image": "watchn/watchn-assets:${var.image_tag}",
    "memory": 512,
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 8080
      }
    ],
    "healthcheck": {
      "command" : [ 
        "CMD-SHELL", "curl -f http://localhost:8080/health.html || exit 1"
      ],
      "interval" : 30,
      "retries" : 3,
      "startPeriod" : 15,
      "timeout" : 10
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