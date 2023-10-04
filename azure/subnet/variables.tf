variable "subnet_name" {
  type = string
  default = "subnet"
}
variable "resource_group_name" {
  type = string
  default = "main"
}
variable "vnet_name" {
  type = string
  default = "main"
}
variable "address_prefixes" {
  type = string
  default = "10.0.1.0/24"
}