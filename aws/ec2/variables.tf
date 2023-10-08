variable "ami_owner" {
  type = string
  default = "amazon"
}
variable "ami_name" {
  type = string
  default = "amzn2-ami-hvm*"
}
variable "instance_type" {
  type = string
  default = "t2.micro"
}
variable "instance_name" {
  type = string
  default = "generic-web"
}
variable "script_path" {
  type = string
  default = "./bootstrap.sh"
}
variable "key_name" {
  type = string
  default = "viper"
}
