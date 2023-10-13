provider "azurerm" {
  features {}
}
provider "random" {
}

# fetch my ip
data "http" "meuip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  common_tags = var.common_tags
  local_tags = {
    "Company" = "b2"
  }
}

#create a random string
resource "random_string" "main" {
  length  = 6
  upper   = false
  special = false
  numeric = false
}

#create a RG
resource "azurerm_resource_group" "main" {
  name     = "doodle"
  location = var.location
  tags     = merge(local.common_tags, local.local_tags)
}

#create a Storage account
resource "azurerm_storage_account" "main" {
  name                = "doogle${random_string.main.id}"
  resource_group_name = azurerm_resource_group.main.name

  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  enable_https_traffic_only = true

  static_website {
    index_document     = "index.html"
    error_404_document = "error.html"
  }
  blob_properties {
    cors_rule {
      allowed_methods    = var.allowed_methods
      allowed_origins    = var.allowed_origins
      allowed_headers    = var.allowed_headers
      exposed_headers    = var.exposed_headers
      max_age_in_seconds = var.max_age_in_seconds
    }
  }

  tags = merge(local.common_tags, local.local_tags)
  depends_on = [
    azurerm_resource_group.main,
    random_string.main
  ]
}

#create a network rule blocking all and allowing access just to cdn
resource "azurerm_storage_account_network_rules" "main" {
  storage_account_id = azurerm_storage_account.main.id
  default_action     = "Deny"
  ip_rules = [chomp(data.http.meuip.response_body)] #chomp removes newline characters at the end of a string
  bypass             = ["AzureServices", "Logging", "Metrics"]
  depends_on         = [azurerm_storage_account.main]
}

# create a front door cdn profile
resource "azurerm_cdn_profile" "main" {
  name                = "profile-${random_string.main.id}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard_Microsoft"
  tags                = merge(local.common_tags, local.local_tags)
  depends_on          = [azurerm_storage_account.main]
}

#create the endpoint
resource "azurerm_cdn_endpoint" "main" {
  name                          = "endpoint-${random_string.main.id}"
  profile_name                  = azurerm_cdn_profile.main.name
  location                      = "Global"
  resource_group_name           = azurerm_resource_group.main.name
  is_http_allowed               = true
  is_https_allowed              = true
  querystring_caching_behaviour = "IgnoreQueryString"
  is_compression_enabled        = true
  origin_host_header            = azurerm_storage_account.main.primary_web_host
  content_types_to_compress = [
    "text/html",
    "text/plain",
  ]

  origin {
    name      = "websiteorginaccount"
    host_name = azurerm_storage_account.main.primary_web_host
  }
  tags       = merge(local.common_tags, local.local_tags)
  depends_on = [azurerm_cdn_profile.main]
}