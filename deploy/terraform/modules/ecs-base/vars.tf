variable "environment_name" {
  default = "watchn"
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

variable "ecs_deployment_controller" {
  default = "ECS"
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

variable "carts_chaos" {
  type = string
  default = ""

  validation {
    condition     = contains(["", "errors", "latency"], var.carts_chaos)
    error_message = "The carts_chaos parameter must be either '', 'errors', or 'latency'."
  }
}

variable "fargate" {
  default = true
}

variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type used for ASG capacity providers"
  default     = "c5a.xlarge"
}

variable "ami_override_id" {
  type        = string
  description = "AMI ID to override the SSM parameter lookup, for testing upgrades"
  default     = ""
}