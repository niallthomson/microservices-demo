locals {
  full_environment_prefix = var.environment_name
}

resource "null_resource" "cluster_blocker" {
  provisioner "local-exec" {
    command = "sleep 30 && echo ${join(",", aws_eks_node_group.managed_workers.*.id)}"
  }
}

data "aws_caller_identity" "current" {}