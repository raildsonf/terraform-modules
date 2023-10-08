provider "aws" {
  region = "us-east-2"
}
module "webappx" {
  source = "../modules/ec2"
  instance_name = "webappx"
  script_path = "init.sh"
}
