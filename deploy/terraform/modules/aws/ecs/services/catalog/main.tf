module "app_service" {
  source = "../../app-service"

  environment_name          = var.environment_name
  service_name              = "catalog"
  region                    = var.region
  cluster_id                = var.cluster_id
  ecs_deployment_controller = var.ecs_deployment_controller
  vpc_id                    = var.vpc_id
  subnet_ids                = var.subnet_ids
  security_group_ids        = [ var.task_sg_id, aws_security_group.catalog.id ]
  lb_security_group_id      = var.lb_security_group_id
  sd_namespace_id           = var.sd_namespace_id
  cpu                       = 256
  memory                    = 512
  fargate                   = var.fargate
  ssm_kms_policy_arn        = var.ssm_kms_policy_arn
  docker_labels             = {
    "platform" = "go"
  }

  container_image           = "watchn/watchn-catalog:${var.image_tag}"
  environment               = [{
    name  = "DB_ENDPOINT",
    value = module.catalog_rds.writer_endpoint
  },{
    name  = "DB_USER",
    value = module.catalog_rds.username
  },{
    name  = "DB_READ_ENDPOINT",
    value = module.catalog_rds.reader_endpoint
  },{
    name  = "DB_NAME",
    value = "catalog"
  }]
  secrets               = [{
    name      = "DB_PASSWORD",
    valueFrom = module.catalog_rds.password_ssm_name
  }]

  #cloudwatch_dashboard_elements = "${data.template_file.catalog_dashboard_elements.rendered},${module.catalog_rds.cloudwatch_dashboard_elements}"
  cloudwatch_dashboard_elements = module.catalog_rds.cloudwatch_dashboard_elements
}

resource "aws_security_group" "catalog" {
  name_prefix = "${var.environment_name}-catalog"
  vpc_id      = var.vpc_id

  description = "Marker SG for catalog service"
}

resource "aws_security_group_rule" "catalog_rds_ingress" {
  description = "Allow access from catalog ECS task"

  type                      = "ingress"
  from_port                 = 3306
  to_port                   = 3306
  protocol                  = "tcp"
  source_security_group_id  = aws_security_group.catalog.id
  security_group_id         = module.catalog_rds.security_group_id
}

module "catalog_rds" {
  source = "../../../rds-mysql"

  environment_name = var.environment_name
  instance_name    = "catalog"
  vpc_id           = var.vpc_id
  subnet_ids       = var.database_subnet_ids
  db_name          = "catalog"
  ssm_key_id       = var.ssm_key_id
}

resource "aws_iam_role_policy" "catalog_execution" {
  name = "${var.environment_name}-catalog-execution"
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
        "${module.catalog_rds.password_ssm_arn}"
      ]
    }
  ]
}
EOF
}