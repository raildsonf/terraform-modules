locals {
  common_tags = var.tags
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags = local.common_tags
}