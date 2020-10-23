variable "cluster_blocker" {
  
}

variable "ui_domain" {
  
}

variable "ui_istio_enabled" {
  default = false
}

variable "carts_eks_service_account_arn" {
  default = ""
}

variable "carts_dynamodb_table_name" {
  default = "Items"
}

variable "carts_dynamodb_create" {
  default = true
}

variable "catalog_mysql_create" {
  default = true
}

variable "orders_mysql_create" {
  default = true
}

variable "orders_activemq_url" {
  default = ""
}

variable "orders_activemq_user" {
  default = ""
}

variable "orders_activemq_password" {
  default = ""
}

variable "checkout_redis_create" {
  default = true
}

variable "checkout_redis_address" {
  default = "redis"
}