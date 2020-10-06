output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_network_acl" {
  value = module.vpc.public_network_acl_id
}

output "private_network_acls" {
  value = length(aws_network_acl.main.*.id) > 0 ? zipmap(var.availability_zones, aws_network_acl.main.*.id) : {}
}

output "nginx_ingress_eips" {
  value = aws_eip.nginx_ingress.*.public_ip
}

output "store_dns" {
  value = local.store_dns
}