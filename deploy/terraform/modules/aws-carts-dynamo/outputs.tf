output "table_name" {
  value = aws_dynamodb_table.carts.name
}

output "role_arn" {
  value = module.iam_assumable_role_carts.this_iam_role_arn
}