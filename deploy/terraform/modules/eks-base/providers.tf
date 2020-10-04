provider "aws" {
  region = var.region

  version = "~> 3.3.0"
}

data "aws_eks_cluster_auth" "default" {
  name = aws_eks_cluster.cluster.name
}

provider "kubernetes" {
  host                   = aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.default.token
  cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority.0.data)
  load_config_file       = false

  version = "~> 1.13.2"
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.default.token
    cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority.0.data)
    load_config_file       = false
  }

  version = "~> 1.3.1"
}

/*provider "kubernetes-alpha" {
  host                   = aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.default.token
  cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority.0.data)
  
  version = "~> 0.2.1"
}*/