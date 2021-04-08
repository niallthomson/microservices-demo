variable "environment_name" {
  default = "watchn"
}

variable "eks_version" {
  default = "1.18"
}

variable "region" {
}

variable "availability_zones" {
  type = list(string)
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "node_pool_instance_type_x64" {
  default = "t3a.large"
}

variable "node_pool_instance_type_arm64" {
  default = "t4g.large"
}

variable "graviton2" {
  description = "Whether to deploy EC2-based services on ARM-based Graviton2 instances"
  default     = false
}

variable "tags" {
  default = {}
}

variable "dns_hosted_zone_id" {

}

variable "dns_base" {

}

variable "dns_prefix" {

}

variable "kubernetes_namespace" {
  default = "watchn"
}

variable "service_mesh" {
  default = "none"
}

variable "aurora_engine_version" {
  default = "5.7.mysql_aurora.2.09.1"
}

variable "aurora_source_region" {
  default = ""
}

variable "catalog_rds_blocker" {
  default = ""
}

variable "catalog_rds_global_cluster_id" {
  default = null
}

variable "catalog_db_password" {
  default = ""
}

variable "orders_rds_blocker" {
  default = ""
}

variable "orders_rds_global_cluster_id" {
  default = null
}

variable "orders_db_password" {
  default = ""
}

variable "carts_dynamo_create_table" {
  default = true
}

variable "carts_dynamo_table_name" {
  default = ""
}