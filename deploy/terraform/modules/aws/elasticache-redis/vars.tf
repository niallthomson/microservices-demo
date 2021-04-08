variable "environment_name" {
}

variable "instance_name" {
}

variable "instance_type" {
  default = "cache.t3.small"
}

variable "vpc_id" {
  
}

variable "subnet_ids" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}