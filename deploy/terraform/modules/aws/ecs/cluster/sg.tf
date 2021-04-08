resource "aws_security_group" "lb_sg" {
  description = "Marker security group for tasks to allow ingress"

  vpc_id      = var.vpc_id
  name_prefix = "${var.environment_name}-lb"
}

resource "aws_security_group" "nsg_task" {
  name        = "${var.environment_name}-task"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "nsg_task_ingress_rule" {
  description              = "Allow connections from LB for tasks on port 8080"
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb_sg.id

  security_group_id = aws_security_group.nsg_task.id
}

resource "aws_security_group_rule" "nsg_task_self_rule" {
  description              = "Allow the tasks to communicate with each other"
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nsg_task.id

  security_group_id = aws_security_group.nsg_task.id
}

resource "aws_security_group_rule" "nsg_task_egress_rule" {
  description = "Allows task to establish connections to all resources"
  type        = "egress"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.nsg_task.id
}