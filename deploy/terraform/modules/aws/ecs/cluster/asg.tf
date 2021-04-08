locals {
  base_ami_id = var.graviton2 ? data.aws_ssm_parameter.ecs_ami_arm64.value : data.aws_ssm_parameter.ecs_ami_x64.value
  ami_id   = var.ami_override_id == "" ? local.base_ami_id : var.ami_override_id
  asg_list = concat(aws_autoscaling_group.ecs_ondemand.*.name, [aws_autoscaling_group.ecs_spot.name])
  spot_instance_types = var.graviton2 ? var.spot_instance_types_arm64 : var.spot_instance_types_x64
}

data "aws_ssm_parameter" "ecs_ami_x64" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

data "aws_ssm_parameter" "ecs_ami_arm64" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/arm64/recommended/image_id"
}

data "template_cloudinit_config" "asg_userdata_ondemand" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<EOT
#!/bin/bash
echo ECS_CLUSTER="${var.environment_name}" >> /etc/ecs/ecs.config
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_SPOT_INSTANCE_DRAINING=false >> /etc/ecs/ecs.config
EOT
  }
}

resource "aws_launch_template" "ondemand" {
  name_prefix            = var.environment_name
  image_id               = local.ami_id
  instance_type          = var.graviton2 ? var.ec2_instance_type_arm64 : var.ec2_instance_type_x64
  vpc_security_group_ids = [aws_security_group.asg_sg.id]
  user_data              = data.template_cloudinit_config.asg_userdata_ondemand.rendered
  update_default_version = true

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_node.name
  }
}

resource "aws_autoscaling_group" "ecs_ondemand" {
  count = length(var.subnet_ids)

  name_prefix           = "${var.environment_name}-ondemand-${var.availability_zones[count.index]}"
  max_size              = 40
  min_size              = var.fargate ? 0 : 2
  vpc_zone_identifier   = [var.subnet_ids[count.index]]
  protect_from_scale_in = false
  min_elb_capacity      = var.fargate ? 0 : 2

  launch_template {
    id       = aws_launch_template.ondemand.id
    version  = aws_launch_template.ondemand.latest_version
  }

  lifecycle {
    create_before_destroy = true
  }

  /*instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
      instance_warmup        = 120
    }
  }*/

  initial_lifecycle_hook {
    name                 = "ecs-drain"
    default_result       = "ABANDON"
    heartbeat_timeout    = 900
    lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"

    notification_target_arn = aws_sns_topic.drain_lambda_sns.arn
    role_arn                = aws_iam_role.asg_drain_lifecycle.arn
  }

  tag {
    key                 = "AmazonECSManaged"
    propagate_at_launch = true
    value               = ""
  }

  tag {
    key                 = "watchn-environment"
    propagate_at_launch = false
    value               = var.environment_name
  }
}

data "template_cloudinit_config" "asg_userdata_spot" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<EOT
#!/bin/bash
echo ECS_CLUSTER="${var.environment_name}" >> /etc/ecs/ecs.config
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_SPOT_INSTANCE_DRAINING=true >> /etc/ecs/ecs.config
EOT
  }
}

resource "aws_launch_template" "spot" {
  name_prefix            = var.environment_name
  image_id               = local.ami_id
  instance_type          = var.graviton2 ? var.ec2_instance_type_arm64 : var.ec2_instance_type_x64
  vpc_security_group_ids = [aws_security_group.asg_sg.id]
  user_data              = data.template_cloudinit_config.asg_userdata_ondemand.rendered
  update_default_version = true

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_node.name
  }
}

resource "aws_autoscaling_group" "ecs_spot" {
  name_prefix           = "${var.environment_name}-spot"
  max_size              = 40
  min_size              = 0
  vpc_zone_identifier   = var.subnet_ids
  protect_from_scale_in = false

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.spot.id
      }

      dynamic "override" {
        for_each = local.spot_instance_types
        iterator = type

        content {
          instance_type     = type.value
          weighted_capacity = 4
        }
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  /*instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
      instance_warmup        = 120
    }
  }*/

  tag {
    key                 = "AmazonECSManaged"
    propagate_at_launch = true
    value               = ""
  }

  tag {
    key                 = "watchn-environment"
    propagate_at_launch = false
    value               = var.environment_name
  }
}

resource "aws_security_group" "asg_sg" {
  name_prefix   = "${var.environment_name}-asg"
  vpc_id        = var.vpc_id
}

resource "aws_security_group_rule" "asg_ingress" {
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.asg_sg.id
  security_group_id        = aws_security_group.asg_sg.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "asg_egress" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.asg_sg.id
  type              = "egress"
}