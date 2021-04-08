locals {
  actual_dns_prefix = var.dns_prefix == "" ? "" : ".${var.dns_prefix}"
  store_dns_prefix = "store${local.actual_dns_prefix}"
  store_dns = "${local.store_dns_prefix}.${var.dns_base}"
  monitoring_dns_prefix = "mon${local.actual_dns_prefix}"
  prometheus_dns = "prometheus.${local.monitoring_dns_prefix}.${var.dns_base}"
  grafana_dns = "grafana.${local.monitoring_dns_prefix}.${var.dns_base}"
}