resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_s3_bucket" "build_artifact_bucket" {
  bucket        = "${var.environment_name}-artifacts-${random_string.random.result}"
  acl           = "private"
  force_destroy = true
}

resource "aws_kms_key" "artifact_encryption_key" {
  description             = "artifact-encryption-key"
  deletion_window_in_days = 10
}