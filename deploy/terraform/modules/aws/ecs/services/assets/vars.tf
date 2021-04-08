variable "environment_name" {
  
}

variable "region" {
  
}

variable "cluster_id" {
  
}

variable "ecs_deployment_controller" {

}

variable "image_tag" {
  
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "task_sg_id" {

}

variable "lb_security_group_id" {

}

variable "sd_namespace_id" {

}

variable "ssm_kms_policy_arn" {

}

variable "tags" {
  default = {}
}

variable "fargate" {

}