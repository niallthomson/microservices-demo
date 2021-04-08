resource "aws_alb_target_group" "main" {
  name                 = var.environment_name
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 30
  target_type          = "ip"

  health_check {
    path                = "/"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 20
    matcher             = "200-399"
  }
}

resource "aws_alb" "main" {
  name            = var.environment_name
  subnets         = var.public_subnet_ids
  security_groups = [aws_security_group.ui_lb_sg.id, var.lb_security_group_id]
}

resource "aws_alb_listener" "front_end_ssl" {
  load_balancer_arn = aws_alb.main.id

  port            = "443"
  protocol        = "HTTPS"
  ssl_policy      = "ELBSecurityPolicy-2015-05"
  certificate_arn = aws_acm_certificate_validation.default.certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.id

  port     = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}

resource "aws_security_group" "ui_lb_sg" {
  description = "controls access to the application ELB"

  vpc_id      = var.vpc_id
  name_prefix = "${var.environment_name}-lb-ui"

  lifecycle {
    ignore_changes = [ingress]
  }
}

resource "aws_security_group_rule" "ui_alb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ui_lb_sg.id
}

resource "aws_security_group_rule" "ui_alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ui_lb_sg.id
}

resource "aws_security_group_rule" "alb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ui_lb_sg.id
}