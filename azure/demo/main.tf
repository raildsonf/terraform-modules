terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.2"
    }
  }
}
provider "azurerm" {
  features {}
}

module "resource_group" {
  source              = "github.com/raildsonf/terraform-modules.git//azure/resource-group?ref=main"
  resource_group_name = "main"
  location            = "East US"
  tags                = var.tags
}

module "vnet" {
  source              = "github.com/raildsonf/terraform-modules.git//azure/vnet?ref=main"
  resource_group_name = "main"
  location            = "East US"
  vnet_name           = "main"
  address_space       = "10.0.0.0/16"
  tags                = var.tags
  depends_on          = [module.resource_group]
}

module "subnets" {
  for_each            = var.subnet_ranges
  source              = "github.com/raildsonf/terraform-modules.git//azure/subnet?ref=main"
  subnet_name         = "subnet-${each.key}"
  resource_group_name = "main"
  vnet_name           = "main"
  address_prefixes    = each.value
  depends_on          = [module.vnet]
}