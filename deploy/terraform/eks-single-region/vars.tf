variable "environment_name" {
  default = "watchn-eks"
}

variable "region" {
  default = "us-west-2"
}

variable "availability_zones" {
  type = list(string)
  default = []
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "hosted_zone_name" {
  
}

variable "dns_prefix" {
  default = ""
}

variable "service_mesh" {
  default = "none"
}

variable "graviton2" {
  description = "Whether to deploy EC2-based services on ARM-based Graviton2 instances"
  default     = false
}