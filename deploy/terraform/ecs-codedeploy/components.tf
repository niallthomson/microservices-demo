locals {
  components = toset(["catalog", "cart", "orders", "checkout", "assets"])
}

module "component_pipelines" {
  source = "./component-pipeline"

  environment_name        = var.environment_name
  component               = each.key
  ecs_cluster_name        = module.ecs_base.ecs_cluster_name
  ecs_service_name        = module.ecs_base.ecs_service_names[each.key]
  vpc_id                  = module.ecs_base.vpc_id
  alb_arn_suffix          = module.ecs_base.alb_arn_suffixes[each.key]
  alb_listener_arn        = module.ecs_base.alb_listener_ids[each.key]
  alb_target_group_name   = module.ecs_base.alb_target_group_names[each.key]
  healthcheck_path        = module.ecs_base.health_checks[each.key]
  codedeploy_role_arn     = aws_iam_role.codedeploy.arn
  codepipeline_role_arn   = aws_iam_role.codepipeline.arn
  codecommit_repo         = aws_codecommit_repository.repo.repository_name
  codecommit_lambda_arn   = aws_lambda_function.codecommit_lambda.arn
  build_project_name      = aws_codebuild_project.component_build.name
  prepare_project_name    = aws_codebuild_project.component_prepare.name
  artifact_bucket_name    = aws_s3_bucket.build_artifact_bucket.bucket
  artifact_bucket_kms_key = aws_kms_key.artifact_encryption_key.arn

  for_each = local.components
}