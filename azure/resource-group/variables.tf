variable "resource_group_name" {
  type = string
  default = "main"
}
variable "location" {
  type = string
  default = "West US"
}
variable "tags" {
  type = map(string)
  default = {
    TEAM = "GK",
    STACK = "webtier",
    OU = "SRE"
  }
}