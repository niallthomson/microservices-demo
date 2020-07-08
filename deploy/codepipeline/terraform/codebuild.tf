data "template_file" "buildspec" {
  count    = length(var.components)

  template = file("templates/buildspec.yml")
  vars = {
    env                = var.environment_name
    component          = var.components[count.index]
    ecr_repository_url = aws_ecr_repository.components[count.index].repository_url
  }
}

resource "aws_codebuild_project" "component_build" {
  count    = length(var.components)

  badge_enabled  = false
  build_timeout  = 60
  name           = "${var.environment_name}-${var.components[count.index]}-build"
  queued_timeout = 480
  service_role   = aws_iam_role.codebuild.arn
  tags = {
    Environment = var.environment_name
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }

  /*logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }*/

  source {
    buildspec           = data.template_file.buildspec[count.index].rendered
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}

resource "aws_iam_role" "codebuild" {
  name = "${var.environment_name}-codebuild"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild" {
  role = aws_iam_role.codebuild.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    }
  ]
}
POLICY
}

data "aws_iam_policy" "ecr_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "codebuild_ecr_full_access_attach" {
  role       = aws_iam_role.codebuild.name
  policy_arn = data.aws_iam_policy.ecr_full_access.arn
}