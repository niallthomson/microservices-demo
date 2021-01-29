resource "aws_ssm_parameter" "password" {
  name   = "/${var.environment_name}/mq-password"
  type   = "SecureString"
  value  = random_password.password.result
  key_id = var.ssm_key_id
}