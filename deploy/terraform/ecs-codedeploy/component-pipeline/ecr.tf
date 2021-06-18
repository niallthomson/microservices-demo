resource "aws_ecr_repository" "repository" {
  name                 = "${var.environment_name}-${var.component}"
  image_tag_mutability = "MUTABLE"
}