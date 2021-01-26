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

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type    = string
  default = null
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
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

variable "capacity_provider_ec2" {
  type = string
}

variable health_check_grace_period {
  default = 0
}