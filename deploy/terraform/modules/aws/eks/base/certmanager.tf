resource "aws_iam_policy" "certmanager_policy" {
  name        = "${var.environment_name}-certmanager"
  path        = "/"
  description = "DNS access for certmanager"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:GetChange",
      "Resource": "arn:aws:route53:::change/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/${var.dns_hosted_zone_id}"
    },
    {
      "Effect": "Allow",
      "Action": "route53:ListHostedZonesByName",
      "Resource": "*"
    }
  ]
}
EOF
}

module "iam_assumable_role_certmanager" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.13.0"
  create_role                   = true
  role_name                     = "${local.full_environment_prefix}-certmanager"
  provider_url                  = local.eks_cluster_issuer_domain
  role_policy_arns              = [aws_iam_policy.certmanager_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${kubernetes_namespace.certmanager.metadata.0.name}:certmanager"]
}

resource "kubernetes_namespace" "certmanager" {
  depends_on = [null_resource.cluster_blocker]

  metadata {
    name = "cert-manager"
  }
}

data "template_file" "certmanager_values" {
  template = file("${path.module}/templates/certmanager-values.yml")

  vars = {
    role_arn = module.iam_assumable_role_certmanager.this_iam_role_arn
  }
}

resource "helm_release" "certmanager" {
  depends_on = [null_resource.cluster_blocker]

  name       = "certmanager"
  namespace  = kubernetes_namespace.certmanager.metadata.0.name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v0.15.2"
  replace    = true

  values = [data.template_file.certmanager_values.rendered]

  provisioner "local-exec" {
    command = "sleep 30"
  }

  provisioner "local-exec" {
    command = <<EOT
cat <<EOF | kubectl --server=${aws_eks_cluster.cluster.endpoint} --insecure-skip-tls-verify=true --token=${data.aws_eks_cluster_auth.default.token} create -f -
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
  namespace: ${kubernetes_namespace.certmanager.metadata.0.name}
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: 'none@paasify.org'
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - selector:
        dnsZones:
        - "${var.dns_base}"
      dns01:
        route53:
          region: ${var.region}
          hostedZoneID: ${var.dns_hosted_zone_id}
EOF
EOT
  }
}