output "namespace" {
  value = kubernetes_namespace.watchn.metadata[0].name
}