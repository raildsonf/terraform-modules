provider "aws" {
  region = "us-east-2"
}

module "palmeiras" {
  source          = "github.com/raildsonf/terraform-modules.git//aws/codecommit?ref=v1.0.1"
  region          = "us-east-2"
  repository_name = "palmeiras"
  default_branch  = "master"
  default_tags = {
    Team = "admin"
    OU   = "SRE"
  }
  component_url = "https://github.com/raildsonf/terraform-modules.git"
}