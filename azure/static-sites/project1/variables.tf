variable "location" {
  type    = string
  default = "East US"
}
variable "common_tags" {
  type = map(string)
  default = {
    "Project" = "home"
    "Team"    = "SRE"
    "Tier"    = "frontend"
  }
}
variable "allowed_methods" {
  type = list(string)
  default = [
    "GET",
    "HEAD"
  ]
}
variable "allowed_origins" {
  type    = list(string)
  default = ["*"]
}
variable "allowed_headers" {
  type    = list(string)
  default = ["*"]
}
variable "exposed_headers" {
  type    = list(string)
  default = ["*"]
}
variable "max_age_in_seconds" {
  type    = number
  default = 300
}