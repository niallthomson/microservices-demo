variable "environment_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "region" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "container_definitions" {
  type    = string
  default = ""
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
  type    = string
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
  type    = bool
  default = true
}

variable "health_check_grace_period" {
  type    = number
  default = 0
}

variable "ssm_kms_policy_arn" {
  type = string
}

variable "secrets" {
  type = list(object({
    name = string
    valueFrom = string
  }))
  default = []
}

variable "environment" {
  type = list(object({
    name = string
    value = string
  }))
  default = []
}

variable "container_image" {
  type = string
}

variable readonly_filesystem {
  type    = bool
  default = true
}

variable "drop_capabilities" {
  type    = bool
  default = true
}

variable "cloudwatch_dashboard_elements" {
  type    = string
  default = ""
}

variable "docker_labels" {
  type    = map(string)
  default = {}
}