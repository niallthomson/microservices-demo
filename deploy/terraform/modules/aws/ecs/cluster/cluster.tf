resource "aws_ecs_cluster" "cluster" {
  name = var.environment_name

  setting {
    name = "containerInsights"
    value = "enabled"
  }

  capacity_providers  = concat(aws_ecs_capacity_provider.asg_ondemand.*.name, [aws_ecs_capacity_provider.asg_spot.name, "FARGATE", "FARGATE_SPOT"])

  dynamic "default_capacity_provider_strategy" {
    for_each = var.fargate ? [] : aws_ecs_capacity_provider.asg_ondemand.*.name
    iterator = strategy

    content {
      capacity_provider = strategy.value
      weight            = 1
    }
  }

  dynamic "default_capacity_provider_strategy" {
    for_each = var.fargate ? ["FARGATE"] : []
    iterator = strategy

    content {
      capacity_provider = strategy.value
      base              = 3
      weight            = 1
    }
  }

  default_capacity_provider_strategy {
    capacity_provider  = var.fargate ? "FARGATE_SPOT" : aws_ecs_capacity_provider.asg_spot.name
    weight             = 3
  }

  # We need to terminate all instances before the cluster can be destroyed.
  # (Terraform would handle this automatically if the autoscaling group depended
  #  on the cluster, but we need to have the dependency in the reverse
  #  direction due to the capacity_providers field above).
  provisioner "local-exec" {
    when = destroy

    command = <<CMD
      ASG_NAMES="$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[? Tags[? (Key=='watchn-environment') && Value=='${self.name}']]".AutoScalingGroupName --output text)"

      if [ -n "$ASG_NAMES" ] && [ "$ASG_NAMES" != "None" ]
      then
        for ASG_NAME in $ASG_NAMES
        do
          aws autoscaling delete-auto-scaling-group --auto-scaling-group-name "$ASG_NAME" --force-delete
        done
      fi

      sleep 40
CMD
  }
}

resource "aws_ecs_capacity_provider" "asg_ondemand" {
  count = length(var.subnet_ids)

  name = "${var.environment_name}-ondemand-${var.availability_zones[count.index]}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_ondemand[count.index].arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 10
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_capacity_provider" "asg_spot" {
  name = "${var.environment_name}-spot"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_spot.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 10
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}