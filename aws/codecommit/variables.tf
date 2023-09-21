variable "region" {
  type        = string
  description = "Region"
}

variable "repository_name" {
  type        = string
  description = "Nome do CodeCommit repo"
}

variable "default_branch" {
  type        = string
  description = "Nome do CodeCommit repo"
}

variable "default_tags" {
  type = map(string)
}

variable "component_url" {
  type        = string
  description = "URL do repo de origem"
}