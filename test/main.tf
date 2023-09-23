module "palmeiras" {
  source          = "github.com/raildsonf/terraform-modules.git//aws/codecommit?ref=v1.0.4"
  repository_name = "testeray"
  default_tags = {
    Team          = "admin"
    OU            = "SRE"
  }
}