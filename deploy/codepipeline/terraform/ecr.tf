resource "aws_ecr_repository" "components" {
  count                = length(var.components)
  name                 = "shop-${var.components[count.index]}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}