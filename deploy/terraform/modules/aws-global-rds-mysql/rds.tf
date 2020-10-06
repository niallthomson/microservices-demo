resource "null_resource" "blocker" {
  provisioner "local-exec" {
    command = "echo ${var.blocker}"
  }
}

resource "aws_db_subnet_group" "subnet_group" {
  name        = "${var.environment_name}-${var.instance_name}"
  description = "For Aurora cluster"
  subnet_ids  = var.subnet_ids
}

resource "random_password" "db_password" {
  length  = 10
  special = false
}

locals {
  rds_password        = var.db_password == "" ? random_password.db_password.result : var.db_password
  rds_master_username = var.blocker == "" ? "root" : ""
  rds_master_password = var.blocker == "" ? local.rds_password : ""
  rds_database_name   = var.blocker == "" ? var.db_name : ""
}

resource "aws_rds_cluster" "rds_cluster" {
  depends_on = [null_resource.blocker]

  global_cluster_identifier       = var.global_cluster_id
  cluster_identifier              = "${var.environment_name}-${var.instance_name}"
  engine                          = "aurora-mysql"
  engine_version                  = var.aurora_engine_version
  engine_mode                     = "global"
  master_username                 = local.rds_master_username
  master_password                 = local.rds_master_password
  database_name                   = local.rds_database_name
  skip_final_snapshot             = true
  deletion_protection             = false
  backup_retention_period         = 7
  preferred_backup_window         = "02:00-03:00"
  preferred_maintenance_window    = "sun:05:00-sun:06:00"
  db_subnet_group_name            = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids          = [aws_security_group.rds.id]
  storage_encrypted               = true
  kms_key_id                      = aws_kms_key.kms.arn
  apply_immediately               = true
  source_region                   = var.aurora_source_region
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cluster_parameter_group.id

  tags = var.tags

  lifecycle {
    ignore_changes = [
      engine_mode,
      replication_source_identifier
    ]
  }
}

resource "null_resource" "out_blocker" {
  depends_on = [aws_rds_cluster_instance.instance_primary]
}

resource "aws_rds_cluster_instance" "instance_primary" {
  identifier                   = "${var.environment_name}-${var.instance_name}-1"
  cluster_identifier           = aws_rds_cluster.rds_cluster.id
  engine                       = "aurora-mysql"
  engine_version               = var.aurora_engine_version
  instance_class               = var.instance_type
  publicly_accessible          = false
  db_subnet_group_name         = aws_db_subnet_group.subnet_group.name
  db_parameter_group_name      = aws_db_parameter_group.parameter_group.id
  preferred_maintenance_window = "sun:05:00-sun:06:00"
  apply_immediately            = true
  promotion_tier               = 1

  tags = var.tags
}

resource "aws_rds_cluster_instance" "instance_others" {
  depends_on = [aws_rds_cluster_instance.instance_primary]

  count = var.read_replica_count

  identifier                   = "${var.environment_name}-${var.instance_name}-${count.index + 2}"
  cluster_identifier           = aws_rds_cluster.rds_cluster.id
  engine                       = "aurora-mysql"
  engine_version               = var.aurora_engine_version
  instance_class               = var.instance_type
  publicly_accessible          = false
  db_subnet_group_name         = aws_db_subnet_group.subnet_group.name
  db_parameter_group_name      = aws_db_parameter_group.parameter_group.id
  preferred_maintenance_window = "sun:05:00-sun:06:00"
  apply_immediately            = true
  promotion_tier               = count.index + 2

  tags = var.tags
}

resource "aws_db_parameter_group" "parameter_group" {
  name        = "${var.environment_name}-${var.instance_name}-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${var.environment_name}-${var.instance_name}-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "cluster_parameter_group" {
  name        = "${var.environment_name}-${var.instance_name}-cluster-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${var.environment_name}-${var.instance_name}-cluster-parameter-group"
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.environment_name}-${var.instance_name}-aurora"
  vpc_id      = var.vpc_id

  description = "Control traffic to/from RDS Aurora"
}

resource "aws_appautoscaling_target" "autoscaling_target" {
  depends_on = [aws_rds_cluster_instance.instance_others]

  count = var.enable_autoscaling ? 1 : 0

  service_namespace  = "rds"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  resource_id        = "cluster:${aws_rds_cluster.rds_cluster.id}"
  min_capacity       = 1
  max_capacity       = 3
}

resource "aws_appautoscaling_policy" "cpu" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "cpu-auto-scaling"
  service_namespace  = aws_appautoscaling_target.autoscaling_target[0].service_namespace
  scalable_dimension = aws_appautoscaling_target.autoscaling_target[0].scalable_dimension
  resource_id        = aws_appautoscaling_target.autoscaling_target[0].resource_id
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "RDSReaderAverageCPUUtilization"
    }

    target_value       = 75
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}