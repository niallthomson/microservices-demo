variable "environment_name" {
  
}

variable "region" {
  
}

variable "cluster_id" {
  
}

variable "cluster_name" {
  
}

variable "image_tag" {
  
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "task_sg_id" {

}

variable "lb_security_group_id" {

}

variable "ssm_kms_policy_arn" {

}

variable "tags" {
  default = {}
}

variable "store_dns" {

}

variable "dns_hosted_zone_id" {

}

variable "catalog_dns" {}
variable "carts_dns" {}
variable "checkout_dns" {}
variable "orders_dns" {}
variable "assets_dns" {}