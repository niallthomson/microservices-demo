resource "aws_eip" "ingress" {
  vpc   = true
  count = length(var.availability_zones)
}