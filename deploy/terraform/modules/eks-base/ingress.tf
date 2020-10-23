resource "aws_eip" "nginx_ingress" {
  vpc   = true
  count = length(var.availability_zones)
}