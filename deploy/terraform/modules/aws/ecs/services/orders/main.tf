module "app_service" {
  source = "../../app-service"

  environment_name          = var.environment_name
  service_name              = "orders"
  region                    = var.region
  cluster_id                = var.cluster_id
  ecs_deployment_controller = var.ecs_deployment_controller
  vpc_id                    = var.vpc_id
  subnet_ids                = var.subnet_ids
  security_group_ids        = [ var.task_sg_id, aws_security_group.orders.id ]
  lb_security_group_id      = var.lb_security_group_id
  sd_namespace_id           = var.sd_namespace_id
  cpu                       = 512
  memory                    = 1024
  health_check_path         = "/actuator/health"
  fargate                   = var.fargate
  ssm_kms_policy_arn        = var.ssm_kms_policy_arn
  docker_labels             = {
    "platform" = "java"
  }

  container_image           = "watchn/watchn-orders:${var.image_tag}"
  environment               = [{
    name  = "SPRING_DATASOURCE_WRITER_URL",
    value = "jdbc:mysql://${module.orders_rds.writer_endpoint}:3306/orders"
  },{
    name  = "SPRING_DATASOURCE_WRITER_USERNAME",
    value = module.orders_rds.username
  },{
    name  = "SPRING_DATASOURCE_READER_URL",
    value = "jdbc:mysql://${module.orders_rds.reader_endpoint}:3306/orders"
  },{
    name  = "SPRING_DATASOURCE_READER_USERNAME",
    value = module.orders_rds.username
  },{
    name  = "SPRING_ACTIVEMQ_BROKERURL",
    value = var.mq_endpoint
  },{
    name  = "SPRING_ACTIVEMQ_USER",
    value = var.mq_username
  },{
    name  = "SPRING_PROFILES_ACTIVE",
    value = "mysql,activemq,prod"
  },{
    name  = "JAVA_OPTS",
    value = "-XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/urandom"
  }]
  secrets               = [{
    name      = "SPRING_DATASOURCE_WRITER_PASSWORD",
    valueFrom = module.orders_rds.password_ssm_name
  },{
    name      = "SPRING_DATASOURCE_READER_PASSWORD",
    valueFrom = module.orders_rds.password_ssm_name
  },{
    name      = "SPRING_ACTIVEMQ_PASSWORD",
    valueFrom = var.mq_password_ssm_name
  }]

  cloudwatch_dashboard_elements = module.orders_rds.cloudwatch_dashboard_elements
}

resource "aws_security_group" "orders" {
  name_prefix = "${var.environment_name}-orders"
  vpc_id      = var.vpc_id

  description = "Marker SG for orders service"
}

resource "aws_security_group_rule" "orders_rds_ingress" {
  description = "Allow access from orders ECS task"

  type                      = "ingress"
  from_port                 = 3306
  to_port                   = 3306
  protocol                  = "tcp"
  source_security_group_id  = aws_security_group.orders.id
  security_group_id         = module.orders_rds.security_group_id
}

module "orders_rds" {
  source = "../../../rds-mysql"

  environment_name = var.environment_name
  instance_name    = "orders"
  vpc_id           = var.vpc_id
  subnet_ids       = var.database_subnet_ids
  db_name          = "orders"
  ssm_key_id       = var.ssm_key_id
}

resource "aws_iam_role_policy" "orders_execution" {
  name = "${var.environment_name}-orders-execution"
  role = module.app_service.execution_role_name

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
        "${module.orders_rds.password_ssm_arn}",
        "${var.mq_password_ssm_arn}"
      ]
    }
  ]
}
EOF
}