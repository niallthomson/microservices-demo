resource "aws_ecs_task_definition" "carts" {
  family                   = "${local.full_environment_prefix}-carts"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  cpu = 256
  memory = 512

  task_role_arn = aws_iam_role.carts_role.arn

  container_definitions    = <<DEFINITION
[
  {
    "name": "carts",
    "image": "watchn/watchn-carts:${var.image_tag}",
    "memory": 512,
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
        "value": "dynamodb"
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
    "healthcheck": {
      "command" : [ 
        "CMD-SHELL", "curl -f http://localhost:8080/actuator/health || exit 1"
      ],
      "interval" : 30,
      "retries" : 3,
      "startPeriod" : 45,
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

resource "aws_ecs_service" "carts" {
  name             = "${local.full_environment_prefix}-carts"
  cluster          = aws_ecs_cluster.cluster.id
  task_definition  = aws_ecs_task_definition.carts.arn
  desired_count    = 3
  platform_version = "1.4.0"

  network_configuration {
    security_groups = [aws_security_group.nsg_task.id, aws_security_group.carts.id]
    subnets         = module.vpc.private_subnets
  }

  service_registries {
    registry_arn = aws_service_discovery_service.carts.arn
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

resource "aws_security_group" "carts" {
  name_prefix = "${var.environment_name}-carts"
  vpc_id      = module.vpc.vpc_id

  description = "Marker SG for carts service"
}

resource "aws_service_discovery_service" "carts" {
  name  = "carts"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.sd.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_iam_role" "carts_role" {
  name = "${local.full_environment_prefix}-carts"
 
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
 
resource "aws_iam_role_policy_attachment" "carts_role_attachment" {
  role       = aws_iam_role.carts_role.name
  policy_arn = aws_iam_policy.carts_dynamo.arn
}