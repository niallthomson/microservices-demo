resource "aws_security_group" "sg" {
  name_prefix = "${var.environment_name}-${var.service_name}"
  vpc_id      = var.vpc_id

  description = "Marker SG for ${var.service_name} service"
}

resource "aws_security_group_rule" "lb_ingress_rule" {
  description              = "Only allow connections from LB tasks on port 8080"
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb_sg.id

  security_group_id = aws_security_group.sg.id
}