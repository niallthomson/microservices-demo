data "template_file" "buildspec_image" {
  template = file("${path.module}/templates/buildspec-build-image.yml")
  vars = {
    dockerhub_username = var.dockerhub_username
    dockerhub_password = aws_ssm_parameter.dockerhub.name
  }
}

resource "aws_codebuild_project" "component_build" {
  badge_enabled  = false
  build_timeout  = 15
  name           = "${var.environment_name}-build"
  queued_timeout = 480
  service_role   = aws_iam_role.codebuild.arn
  tags = {
    Environment = var.environment_name
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
  }

  source {
    buildspec           = data.template_file.buildspec_image.rendered
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}