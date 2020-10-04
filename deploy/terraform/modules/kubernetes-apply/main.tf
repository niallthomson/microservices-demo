resource "null_resource" "blocker" {
  provisioner "local-exec" {
    command = "echo 'unblocked on ${var.blocker}'"
  }
}

resource "kubernetes_service_account" "sa" {
  metadata {
    name = "apply-${var.name}"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "admin" {
  metadata {
    name = "apply-admin-${var.name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.sa.metadata.0.name
    namespace = "kube-system"
  }
}

resource "kubernetes_config_map" "apply_config_map" {
  metadata {
    name = "apply-${var.name}"
    namespace = "kube-system"
  }

  data = {
    yml = var.yaml
  }
}

resource "kubernetes_job" "apply_job" {
  depends_on = [
    null_resource.blocker,
    kubernetes_cluster_role_binding.admin
  ]

  metadata {
    name = "apply-${var.name}"
    namespace = "kube-system"
  }

  spec {
    template {
      metadata {}

      spec {
        container {
          name    = "apply-${var.name}"
          image   = "lachlanevenson/k8s-kubectl:v1.13.10"
          command = ["kubectl", "apply", "-f", "/tmp/config/yml"]

          volume_mount {
            name = "yml"
            mount_path = "/tmp/config"
          }
        }

        volume {
          name = "yml"
          config_map {
            name = kubernetes_config_map.apply_config_map.metadata.0.name
          }
        }
        
        restart_policy = "Never"
        service_account_name = kubernetes_service_account.sa.metadata.0.name
        automount_service_account_token = true
      }
    }

    backoff_limit = 4
  }
}