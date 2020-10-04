variable "environment_name" {
  default = "watchn"
}

variable "image_tag" {
  default = "build.1601746945"
}

variable "region" {
}

variable "availability_zones" {
  type = list(string)
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "tags" {
  default = {}
}

variable "dns_hosted_zone_id" {

}

variable "dns_base" {

}

variable "dns_suffix" {

}

variable "aurora_engine_version" {
  default = "5.7.mysql_aurora.2.08.1"
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