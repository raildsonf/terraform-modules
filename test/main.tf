module "palmeiras" {
  source          = "github.com/raildsonf/terraform-modules.git//aws/codecommit?ref=v1.0.2"
  region          = "us-east-2"
  repository_name = "palmeiras"
  default_branch  = "master"
  default_tags = {
    Team = "admin"
    OU   = "SRE"
    Component_url = "https://github.com/raildsonf/terraform-modules.git"
  }
}