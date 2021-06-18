resource "aws_codepipeline" "pipeline" {
  name     = "${var.environment_name}-${var.component}"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.artifact_bucket_name
    type     = "S3"

    encryption_key {
      id   = var.artifact_bucket_kms_key
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        RepositoryName       = var.codecommit_repo
        BranchName           = "master"
        PollForSourceChanges = "False"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      version          = "1"
      namespace        = "ImageBuild"

      configuration = {
        ProjectName          = var.build_project_name
        EnvironmentVariables = jsonencode([
          {
            name  = "component"
            value = var.component
            type  = "PLAINTEXT"
          },
          {
            name  = "env"
            value = var.environment_name
            type  = "PLAINTEXT"
          },
          {
            name  = "ecr_repository_url"
            value = aws_ecr_repository.repository.repository_url
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }

  stage {
    name = "Prepare"

    action {
      name             = "Prepare"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      output_artifacts = ["prepare"]
      version          = "1"
      namespace        = "Prepare"

      configuration = {
        ProjectName          = var.prepare_project_name
        EnvironmentVariables = jsonencode([
          {
            name  = "Image_ID"
            value = "#{ImageBuild.IMAGE_TAG}"
            type  = "PLAINTEXT"
          },
          {
            name  = "component"
            value = var.component
            type  = "PLAINTEXT"
          },
          {
            name  = "env"
            value = var.environment_name
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeDeployToECS"
      input_artifacts  = ["prepare"]
      version          = "1"
      namespace        = "Deploy"

      configuration = {
        ApplicationName                = aws_codedeploy_app.app.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.deployment_group.deployment_group_name
        TaskDefinitionTemplateArtifact = "prepare"
        AppSpecTemplateArtifact        = "prepare"
      }
    }
  }
}