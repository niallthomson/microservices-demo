resource "aws_security_group" "mq" {
  name        = "${var.environment_name}-mq"
  vpc_id      = var.vpc_id

  description = "Control traffic to/from Amazon MQ"
}

resource "random_password" "password" {
  length  = 16
  special = false
}

resource "aws_mq_broker" "mq" {
  broker_name = "${var.environment_name}-mq"

  engine_type        = "ActiveMQ"
  engine_version     = "5.15.0"
  host_instance_type = var.instance_type
  security_groups    = [aws_security_group.mq.id]
  subnet_ids         = [var.subnet_ids[0]]

  user {
    username = "user"
    password = random_password.password.result
  }
}