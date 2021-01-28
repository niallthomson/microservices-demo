locals {
  ami_id = var.ami_override_id == "" ? data.aws_ssm_parameter.ecs_ami.value : var.ami_override_id
}

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
  image_id               = local.ami_id
  instance_type          = var.ec2_instance_type
  vpc_security_group_ids = [aws_security_group.asg_sg.id]
  user_data              = data.template_cloudinit_config.asg_userdata_ondemand.rendered
  update_default_version = true

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_node.name
  }
}

resource "aws_autoscaling_group" "ecs_ondemand" {
  count = length(module.vpc.private_subnets)

  name_prefix           = "${local.full_environment_prefix}-ondemand-${var.availability_zones[count.index]}"
  max_size              = 40
  min_size              = var.fargate ? 0 : 2
  vpc_zone_identifier   = [module.vpc.private_subnets[count.index]]
  protect_from_scale_in = false
  min_elb_capacity      = var.fargate ? 0 : 2

  launch_template {
    id       = aws_launch_template.node.id
    version  = aws_launch_template.node.latest_version
  }

  lifecycle {
    create_before_destroy = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
    }
  }

  tag {
    key                 = "AmazonECSManaged"
    propagate_at_launch = true
    value               = ""
  }
}

resource "aws_autoscaling_group" "ecs_spot" {
  name_prefix           = "${local.full_environment_prefix}-spot"
  max_size              = 40
  min_size              = 0
  vpc_zone_identifier   = module.vpc.private_subnets
  protect_from_scale_in = false

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.node.id
      }

      override {
        instance_type     = "c5a.xlarge"
        weighted_capacity = "4"
      }

      override {
        instance_type     = "c5.xlarge"
        weighted_capacity = "4"
      }

      override {
        instance_type     = "c5d.xlarge"
        weighted_capacity = "4"
      }

      override {
        instance_type     = "c5a.2xlarge"
        weighted_capacity = "8"
      }

      override {
        instance_type     = "c5.2xlarge"
        weighted_capacity = "8"
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
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