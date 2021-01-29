variable "environment_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "container_definitions" {
  type = string
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "lb_security_group_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "ecs_deployment_controller" {
  default = "ECS"
}

variable "sd_namespace_id" {
  type = string
}

variable "health_check_path" {
  type    = string
  default = "/health"
}

variable "fargate" {
  default = true
}

variable health_check_grace_period {
  default = 0
}

variable ssm_kms_policy_arn {
  type = string
}