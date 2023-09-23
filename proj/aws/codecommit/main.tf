module "main" {
  source          = "github.com/raildsonf/terraform-modules.git//aws/codecommit?ref=v1.0.16"
  repository_name = "teste"
  default_tags = {
    PROJECT = "demo"
    TEAM = "SRE"
  }
}

module "main_trigger" {
  source          = "github.com/raildsonf/terraform-modules.git//aws/codecommit-trigger?ref=v1.0.16"
  repository_name = "teste"
  trigger_name = ["all"]
  aws_sns_topic = "arn:aws:sns:us-east-2:013281578681:testes"
}

module "main_approvals" {
  source          = "github.com/raildsonf/terraform-modules.git//aws/codecommit-approval-rule-template?ref=v1.0.16"
  repository_name = "teste"
  number_approvals = 1
  approval_pool_members = ["arn:aws:iam::013281578681:user/admin"]
}
