variable "environment_name" {
}

variable "instance_type" {
  default = "mq.t2.micro"
}

variable "vpc_id" {
  
}

variable "subnet_ids" {
  type = list(string)
}

variable "ssm_key_id" {
  type    = string
  default = null
}