output "cluster_id" {
  value = aws_ecs_cluster.cluster.id
}

output "cluster_name" {
  value = aws_ecs_cluster.cluster.name
}

output "lb_security_group_id" {
  value = aws_security_group.lb_sg.id
}

output "task_security_group_id" {
  value = aws_security_group.nsg_task.id
}