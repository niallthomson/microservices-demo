variable "environment_name" {

}

variable "repository_name" {
  default = "microservices-demo"
}

variable "repository_owner" {
  default = "niallthomson"
}

variable "components" {
  type = list(string)
  default = ["ui", "cart", "catalog", "orders"]
}