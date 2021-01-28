variable "environment_name" {
  default = "watchn-ecs"
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

variable "fargate" {
  default = true
}

variable "ami_override_id" {
  default = ""
}