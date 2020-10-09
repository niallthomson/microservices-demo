output "wire_endpoint" {
  value = aws_mq_broker.mq.instances.0.endpoints.0
}

output "stomp_endpoint" {
  value = aws_mq_broker.mq.instances.0.endpoints.2
}

output "security_group_id" {
  value = aws_security_group.mq.id
}

output "user" {
  value = "user"
}

output "password" {
  value = random_password.password.result
}