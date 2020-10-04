locals {
  table_name = var.create_table ? aws_dynamodb_table.carts[0].name : var.table_name
}

resource "aws_dynamodb_table" "carts" {
  name             = "${var.environment_name}-carts"
  hash_key         = "id"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "customerId"
    type = "S"
  }

  global_secondary_index {
    name            = "idx_global_customerId"
    hash_key        = "customerId"
    projection_type = "ALL"
  }

  count = var.create_table ? 1 : 0
}