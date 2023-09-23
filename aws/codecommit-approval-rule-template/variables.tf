variable "repository_name" {
    type = string
}
variable "number_approvals" {
  type = string
}
variable "approval_pool_members" {
  type = list(string)
}
variable "region" {
  type        = string
  description = "Region"
  default = "us-east-2"
}