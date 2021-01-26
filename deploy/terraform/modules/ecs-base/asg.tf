data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

data "template_cloudinit_config" "asg_userdata_ondemand" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<EOT
#!/bin/bash
echo ECS_CLUSTER="${local.full_environment_prefix}" >> /etc/ecs/ecs.config
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_SPOT_INSTANCE_DRAINING=false >> /etc/ecs/ecs.config
EOT
  }
}

resource "aws_launch_template" "node" {
  name_prefix            = local.full_environment_prefix
  image_id               = data.aws_ssm_parameter.ecs_ami.value
  instance_type          = var.ec2_instance_type
  vpc_security_group_ids = [aws_security_group.asg_sg.id]
  user_data              = data.template_cloudinit_config.asg_userdata_ondemand.rendered
  update_default_version = true

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_node.name
  }
}

resource "aws_autoscaling_group" "ecs_ondemand" {
  name_prefix           = "${local.full_environment_prefix}-ondemand"
  max_size              = 40
  min_size              = var.fargate ? 0 : length(module.vpc.private_subnets)
  vpc_zone_identifier   = module.vpc.private_subnets
  protect_from_scale_in = false

  launch_template {
    id       = aws_launch_template.node.id
    version  = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "AmazonECSManaged"
    propagate_at_launch = true
    value               = ""
  }
}

resource "aws_security_group" "asg_sg" {
  name_prefix   = "${local.full_environment_prefix}-asg"
  vpc_id        = module.vpc.vpc_id
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

resource "aws_ecs_capacity_provider" "asg_ondemand" {
  name = "${local.full_environment_prefix}-ondemand"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_ondemand.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 10
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}