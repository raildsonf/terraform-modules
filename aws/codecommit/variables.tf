variable "region" {
  type        = string
  description = "Region"
  default = "us-east-2"
}

variable "repository_name" {
  type        = string
  description = "Nome do CodeCommit repo"
}

variable "default_branch" {
  type        = string
  description = "Nome da default branch"
  default = "master"
}

variable "default_tags" {
  type = map(string)
}