module "resource_group_main" {
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

module "vnet_main" {
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
  depends_on = [ module.resource_group_main.resource_group_id ]
}