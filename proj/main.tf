module "main" {
  source          = "github.com/raildsonf/terraform-modules.git//aws/codecommit?ref=v1.0.4"
  repository_name = "teste"
  default_tags = var.default_tags
}