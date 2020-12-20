output "store_endpoint" {
  value = module.eks_base.store_dns
}

output "prometheus_endpoint" {
  value = module.eks_base.prometheus_dns
}

output "grafana_endpoint" {
  value = module.eks_base.grafana_dns
}