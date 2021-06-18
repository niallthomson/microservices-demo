resource "aws_ssm_parameter" "dockerhub" {
  name        = "/watchn/${var.environment_name}/dockerhub_password"
  description = "DockerHub password to authenticate in CodeBuild"
  type        = "SecureString"
  value       = var.dockerhub_password
}