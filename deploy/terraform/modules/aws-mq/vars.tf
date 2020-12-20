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