resource "aws_alb_target_group" "main" {
  name                 = "${var.environment_name}-${var.service_name}"
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 30
  target_type          = "ip"

  health_check {
    path                = var.health_check_path
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 20
    matcher             = "200-399"
  }
}

resource "aws_alb" "main" {
  name            = "${var.environment_name}-${var.service_name}"
  subnets         = var.subnet_ids
  security_groups = [aws_security_group.lb_sg.id, var.lb_security_group_id]
  internal        = true
}

resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.main.id

  port     = 8080
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }

  lifecycle {
    ignore_changes = [
      default_action
    ]
  }
}

resource "aws_security_group" "lb_sg" {
  description = "Controls access to the application ALB"

  vpc_id      = var.vpc_id
  name_prefix = "${var.environment_name}-${var.service_name}-lb"

  lifecycle {
    ignore_changes = [ingress]
  }
}

resource "aws_security_group_rule" "alb_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb_sg.id
}

resource "aws_security_group_rule" "alb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb_sg.id
}