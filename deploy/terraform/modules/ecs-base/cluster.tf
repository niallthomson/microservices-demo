resource "aws_ecs_cluster" "cluster" {
  name = local.full_environment_prefix

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
      # Get the list of capacity providers associated with this cluster
      CAP_PROVS="$(aws ecs describe-clusters --clusters "${self.arn}" \
        --query 'clusters[*].capacityProviders[*]' --output text)"

      # Now get the list of autoscaling groups from those capacity providers
      ASG_ARNS="$(aws ecs describe-capacity-providers \
        --capacity-providers "$CAP_PROVS" \
        --query 'capacityProviders[*].autoScalingGroupProvider.autoScalingGroupArn' \
        --output text)"

      if [ -n "$ASG_ARNS" ] && [ "$ASG_ARNS" != "None" ]
      then
        for ASG_ARN in $ASG_ARNS
        do
          ASG_NAME=$(echo $ASG_ARN | cut -d/ -f2-)

          # Set the autoscaling group size to zero
          aws autoscaling update-auto-scaling-group \
            --auto-scaling-group-name "$ASG_NAME" \
            --min-size 0 --max-size 0 --desired-capacity 0

          # Remove scale-in protection from all instances in the asg
          INSTANCES="$(aws autoscaling describe-auto-scaling-groups \
            --auto-scaling-group-names "$ASG_NAME" \
            --query 'AutoScalingGroups[*].Instances[*].InstanceId' \
            --output text)"
          aws autoscaling set-instance-protection --instance-ids $INSTANCES \
            --auto-scaling-group-name "$ASG_NAME" \
            --no-protected-from-scale-in
        done
      fi
CMD
  }
}

resource "aws_ecs_capacity_provider" "asg_ondemand" {
  count = length(module.vpc.private_subnets)

  name = "${local.full_environment_prefix}-ondemand-${var.availability_zones[count.index]}"

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
  name = "${local.full_environment_prefix}-spot"

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

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/watchn-ecs/${local.full_environment_prefix}"
  retention_in_days = 7
}