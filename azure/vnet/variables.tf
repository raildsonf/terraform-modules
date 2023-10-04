variable "resource_group_name" {
  type = string
  default = "main"
}
variable "vnet_name" {
  type = string
  default = "main"
}
variable "location" {
  type = string
  default = "West US"
}
variable "address_space" {
  type = string
  default = "10.0.0.0/16"
}
variable "tags" {
  type = map(string)
  default = {
    TEAM = "GK",
    STACK = "webtier",
    OU = "SRE"
  }
}