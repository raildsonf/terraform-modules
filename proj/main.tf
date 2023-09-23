module "main" {
  source          = "github.com/raildsonf/terraform-modules.git//aws/codecommit?ref=v1.0.10"
  repository_name = "teste"
  default_tags = var.default_tags
}

module "main_trigger" {
  source          = "github.com/raildsonf/terraform-modules.git//aws/codecommit-trigger?ref=v1.0.10"
  repository_name = "teste"
  trigger_name = ["all"]
  aws_sns_topic = "arn:aws:sns:us-east-2:013281578681:testes"
}
