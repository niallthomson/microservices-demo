variable "cluster_blocker" {
  
}

variable "ui_domain" {
  
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