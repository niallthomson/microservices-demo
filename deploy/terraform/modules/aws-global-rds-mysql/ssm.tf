resource "aws_ssm_parameter" "root_password" {
  name   = "/${var.environment_name}/${var.instance_name}-root-password"
  type   = "SecureString"
  value  = local.rds_password
  key_id = var.ssm_key_id
}

resource "aws_ssm_parameter" "password" {
  name   = "/${var.environment_name}/${var.instance_name}-password"
  type   = "SecureString"
  value  = local.rds_master_password
  key_id = var.ssm_key_id
}