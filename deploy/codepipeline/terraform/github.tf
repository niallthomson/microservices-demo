provider "github" {
  individual = true
}

resource "github_branch" "development" {
  repository = var.repository_name
  branch     = var.environment_name
}