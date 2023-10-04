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
  location            = "West US"
  tags = {
    TEAM    = "GK",
    STACK   = "webtier",
    OU      = "SRE",
    PROJECT = "unit"
  }
}

module "vnet" {
  source              = "github.com/raildsonf/terraform-modules.git//azure/vnet?ref=main"
  resource_group_name = "main"
  location            = "West US"
  vnet_name           = "aks"
  address_space       = "10.0.0.0/16"
  tags = {
    TEAM    = "GK",
    STACK   = "webtier",
    OU      = "SRE",
    PROJECT = "unit"
  }
  depends_on = [ module.resource_group ]
}

module "subnet1" {
  source = "github.com/raildsonf/terraform-modules.git//azure/subnet?ref=main"
  subnet_name = "subnet1"
  resource_group_name = "main"
  vnet_name = "aks"
  address_prefixes = "10.0.1.0/24"
  depends_on = [ module.vnet ]
}