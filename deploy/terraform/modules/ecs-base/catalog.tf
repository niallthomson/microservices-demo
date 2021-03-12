module "catalog_service" {
  source = "../ecs-app-service"

  environment_name          = local.full_environment_prefix
  service_name              = "catalog"
  region                    = var.region
  cluster_id                = aws_ecs_cluster.cluster.id
  ecs_deployment_controller = var.ecs_deployment_controller
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnets
  security_group_ids        = [ aws_security_group.nsg_task.id, aws_security_group.catalog.id ]
  lb_security_group_id      = aws_security_group.lb_sg.id
  sd_namespace_id           = aws_service_discovery_private_dns_namespace.sd.id
  cpu                       = 256
  memory                    = 512
  fargate                   = var.fargate
  ssm_kms_policy_arn        = aws_iam_policy.ssm_kms.arn
  docker_labels             = {
    "platform" = "go"
  }

  container_image           = "watchn/watchn-catalog:${module.image_tag.image_tag}"
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
  name_prefix = "${local.full_environment_prefix}-catalog"
  vpc_id      = module.vpc.vpc_id

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
  source = "../aws-global-rds-mysql"

  environment_name = local.full_environment_prefix
  instance_name    = "catalog"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.database_subnets
  db_name          = "catalog"
  ssm_key_id       = aws_kms_key.ssm_key.key_id
}

resource "aws_iam_role_policy" "catalog_execution" {
  name = "${local.full_environment_prefix}-catalog-execution"
  role = module.catalog_service.execution_role_name

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

data "template_file" "catalog_dashboard_elements" {

  template = <<EOF
{
  "type": "text",
  "width": 24,
  "height": 1,
  "properties": {
    "markdown": "\n# Database Client\n"
  }
},
{
  "type": "metric",
  "width": 12,
  "height": 6,
  "properties": {
    "metrics": [
      [ "ECS/ContainerInsights/Prometheus", "go_sql_stats_connections_idle", "db_name", "db", "TaskDefinitionFamily", "${module.catalog_service.service_name}", "ClusterName", "${aws_ecs_cluster.cluster.name}" ],
      [ ".", "go_sql_stats_connections_max_open", ".", ".", ".", ".", ".", "." ],
      [ ".", "go_sql_stats_connections_open", ".", ".", ".", ".", ".", "." ],
      [ ".", "go_sql_stats_connections_in_use", ".", ".", ".", ".", ".", "." ]
    ],
    "period": 60,
    "stat": "Sum",
    "region": "${var.region}",
    "title": "DB Connections",
    "yAxis": {
        "left": {
            "label": "Count",
            "showUnits": false
        }
    }
  }
},
{
  "type": "metric",
  "width": 12,
  "height": 6,
  "properties": {
    "metrics": [
      [ "ECS/ContainerInsights/Prometheus", "go_sql_stats_connections_idle", "db_name", "reader_db", "TaskDefinitionFamily", "${module.catalog_service.service_name}", "ClusterName", "${aws_ecs_cluster.cluster.name}" ],
      [ ".", "go_sql_stats_connections_max_open", ".", ".", ".", ".", ".", "." ],
      [ ".", "go_sql_stats_connections_open", ".", ".", ".", ".", ".", "." ],
      [ ".", "go_sql_stats_connections_in_use", ".", ".", ".", ".", ".", "." ]
    ],
    "period": 60,
    "stat": "Sum",
    "region": "${var.region}",
    "title": "Reader DB Connections",
    "yAxis": {
        "left": {
            "label": "Count",
            "showUnits": false
        }
    }
  }
}
EOF
}