variable "region" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "num_availability_zones" {
  type    = number
  default = 3
}

variable "availability_zone_map" {
  default = {
    "us-east-1" : ["us-east-1a", "us-east-1b", "us-east-1c"],
    "us-west-2" : ["us-west-2a", "us-west-2b", "us-west-2c"],
    "eu-west-1" : ["eu-west-1a", "eu-west-1b", "eu-west-1c"],
    "eu-central-1" : ["eu-central-1a", "eu-central-1b", "eu-central-1c"],
  }
}

output "availability_zones" {
  value = length(var.availability_zones) > 0 ? var.availability_zones : var.availability_zone_map[var.region]
}