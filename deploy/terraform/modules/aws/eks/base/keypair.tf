resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${local.full_environment_prefix}-default"
  public_key = tls_private_key.default.public_key_openssh
}