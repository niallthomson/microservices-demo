output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_network_acl" {
  value = module.vpc.public_network_acl_id
}

output "private_network_acls" {
  value = length(aws_network_acl.main.*.id) > 0 ? zipmap(var.availability_zones, aws_network_acl.main.*.id) : {}
}

output "app_ingress_eips" {
  value = local.istio_enabled ? aws_eip.istio_ingress.*.public_ip : aws_eip.nginx_ingress.*.public_ip
}

output "utility_ingress_eips" {
  value = aws_eip.nginx_ingress.*.public_ip
}

output "store_dns" {
  value = local.store_dns
}

output "store_dns_prefix" {
  value = local.store_dns_prefix
}

output "prometheus_dns" {
  value = local.prometheus_dns
}

output "grafana_dns" {
  value = local.grafana_dns
}

output "monitoring_dns_prefix" {
  value = local.monitoring_dns_prefix
}