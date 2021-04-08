variable "environment_name" {
  type = string
}

variable "region" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "tags" {
  default = {}
}

variable "fargate" {
  description = "Whether to deploy entirely on Fargate"
  default     = true
}

variable "graviton2" {
  description = "Whether to deploy EC2-based services on ARM-based Graviton2 instances"
  default     = false
}

variable "ec2_instance_type_x64" {
  type        = string
  description = "EC2 instance type used for ASG capacity providers"
  default     = "c5a.xlarge"
}

variable "ec2_instance_type_arm64" {
  type        = string
  description = "EC2 instance type used for ASG capacity providers"
  default     = "c6g.xlarge"
}

variable "spot_instance_types_x64" {
  type        = list(string)
  description = "EC2 instance types used for x64 Spot ASG capacity providers"
  default     = ["c5a.xlarge", "c5.xlarge", "c5d.xlarge"]
}

variable "spot_instance_types_arm64" {
  type        = list(string)
  description = "EC2 instance types used for ARM64 Spot ASG capacity providers"
  default     = ["c6g.xlarge"]
}

variable "ec2_instance_refresh" {
  type        = bool
  description = "Whether to enable instance refresh on the ASGs for the capacity providers"
  default     = true
}

variable "ami_override_id" {
  type        = string
  description = "AMI ID to override the SSM parameter lookup, for testing upgrades"
  default     = ""
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}