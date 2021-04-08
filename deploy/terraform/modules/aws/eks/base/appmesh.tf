locals {
  appmesh_name      = "${local.full_environment_prefix}-mesh"
  appmesh_namespace = "appmesh-system"
  appmesh_enabled   = var.service_mesh == "appmesh" ? true : false
}

resource "kubernetes_namespace" "appmesh_system" {
  depends_on = [null_resource.cluster_blocker]

  count = local.appmesh_enabled ? 1 : 0

  metadata {
    name = local.appmesh_namespace
  }
}

module "iam_assumable_role_appmesh" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.13.0"
  create_role                   = true
  role_name                     = "${local.full_environment_prefix}-appmesh-controller"
  provider_url                  = local.eks_cluster_issuer_domain
  role_policy_arns              = ["arn:aws:iam::aws:policy/AWSCloudMapFullAccess", "arn:aws:iam::aws:policy/AWSAppMeshFullAccess"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.appmesh_namespace}:appmesh-controller"]
}

data "template_file" "appmesh_values" {
  template = file("${path.module}/templates/appmesh-values.yml")

  vars = {
    role_arn = module.iam_assumable_role_appmesh.this_iam_role_arn
  }
}

resource "helm_release" "appmesh_controller" {
  count = local.appmesh_enabled ? 1 : 0

  name       = "appmesh-controller"
  repository = "https://aws.github.io/eks-charts" 
  chart      = "appmesh-controller"
  namespace  = local.appmesh_namespace

  version    = "1.3.0"

  values = [data.template_file.appmesh_values.rendered]
}

resource "helm_release" "appmesh_prometheus" {
  count = local.appmesh_enabled ? 1 : 0

  name       = "appmesh-prometheus"
  repository = "https://aws.github.io/eks-charts" 
  chart      = "appmesh-prometheus"
  namespace  = local.appmesh_namespace

  version    = "1.0.0"
}