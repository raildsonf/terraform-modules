variable "repository_name" {
  type = string
  description = "repo name"
}
variable "trigger_name" {
  type = string
  default = "all"
}
variable "aws_sns_topic" {
  type = string
}
variable "region" {
  type = string
  default = "us-east-2"
}