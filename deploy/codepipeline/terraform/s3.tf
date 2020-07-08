resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.environment_name}-codepipeline"
  acl    = "private"
}