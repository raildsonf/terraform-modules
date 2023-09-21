resource "aws_codecommit_repository" "main" {
  repository_name = var.repository_name
  default_branch  = var.default_branch
  description     = "This is the Sample App Repository"
  tags            = var.default_tags
}