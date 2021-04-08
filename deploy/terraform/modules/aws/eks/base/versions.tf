terraform {
  required_version = ">= 0.14.0"

  required_providers {
    aws        = "~> 3.25.0"
    kubernetes = "~> 2.0.2"
    helm       = "~> 2.0.3"
  }
}