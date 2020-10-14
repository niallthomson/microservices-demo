locals {
  appmesh_name = "${local.full_environment_prefix}-mesh"
}

resource "kubernetes_namespace" "appmesh_system" {
  depends_on = [null_resource.cluster_blocker]

  metadata {
    name = "appmesh-system"
  }
}

module "iam_assumable_role_appmesh" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.20.0"
  create_role                   = true
  role_name                     = "${local.full_environment_prefix}-appmesh-controller"
  provider_url                  = local.eks_cluster_issuer_domain
  role_policy_arns              = ["arn:aws:iam::aws:policy/AWSCloudMapFullAccess", "arn:aws:iam::aws:policy/AWSAppMeshFullAccess"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${kubernetes_namespace.appmesh_system.metadata[0].name}:appmesh-controller"]
}

data "template_file" "appmesh_crds" {
  template = file("${path.module}/templates/appmesh-crds.yml")
}

module "appmesh_crd_apply" {
  source = "../kubernetes-apply"

  name = "appmesh-crd"
  blocker = null_resource.cluster_blocker.id
  yaml = data.template_file.appmesh_crds.rendered
}

data "template_file" "appmesh_values" {
  template = file("${path.module}/templates/appmesh-values.yml")

  vars = {
    role_arn = module.iam_assumable_role_appmesh.this_iam_role_arn
  }
}

resource "helm_release" "appmesh_controller" {
  depends_on = [module.appmesh_crd_apply]

  name       = "appmesh-controller"
  repository = "https://aws.github.io/eks-charts" 
  chart      = "appmesh-controller"
  namespace  = kubernetes_namespace.appmesh_system.metadata[0].name

  version    = "1.1.0"

  values = [data.template_file.appmesh_values.rendered]
}

resource "helm_release" "appmesh_prometheus" {
  depends_on = [module.appmesh_crd_apply]

  name       = "appmesh-prometheus"
  repository = "https://aws.github.io/eks-charts" 
  chart      = "appmesh-prometheus"
  namespace  = kubernetes_namespace.appmesh_system.metadata[0].name

  version    = "1.0.0"
}