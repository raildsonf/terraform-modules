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

variable "tags" {
  type = map(string)
  default = {
    TEAM = "GK",
    STACK = "webtier",
    OU = "SRE"
  }
}

# 1. Create a service principal
data "azuread_client_config" "current" {} #read data from client config

resource "azuread_application" "main" {
  display_name = "spnaks"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "main" {
  application_id               = azuread_application.main.application_id
  app_role_assignment_required = true
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "main" {
  service_principal_id = azuread_service_principal.main.object_id #hold the spn id
}

resource "azurerm_role_assignment" "main" {
  scope                = "/subscriptions/{id da subscript 1 aqui}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.main.object_id
}

# 2. Create a key vault
resource "azurerm_key_vault" "main" {
  name                        = "aksb2intb"
  location                    = "East US"
  resource_group_name         = "main"
  enabled_for_disk_encryption = true
  tenant_id                   = data.azuread_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "premium"
}

resource "azurerm_key_vault_access_policy" "main" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azuread_client_config.current.tenant_id
  object_id    = data.azuread_client_config.current.object_id
  secret_permissions = [
    "Delete",
    "Get",
    "Set",
    "List"
  ]
}

resource "azurerm_key_vault_secret" "main" {
  name         = azuread_application.main.application_id
  value        = azuread_service_principal_password.main.value
  key_vault_id = azurerm_key_vault.main.id
}

# 3. Create the AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = "conta-digital"
  kubernetes_version = "1.27.3"
  location            = "East US"
  resource_group_name = "main"
  dns_prefix          = "conta-digital"

  default_node_pool {
    name            = "default"
    zones           = [1, 2, 3]
    vm_size         = "Standard_D2_v2"
    min_count       = 1
    max_count       = 3
    os_disk_size_gb = 90
    enable_auto_scaling = true
    type            = "VirtualMachineScaleSets"
    node_labels = {
      "node-pool" = "system",
      "env"       = "prd",
      "type"      = "linux"
    }
    tags = var.tags
  }

  service_principal {
    client_id     = azuread_application.main.application_id
    client_secret = azuread_service_principal_password.main.value
  }

  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }
}

# 4. Create Node Pools
resource "azurerm_kubernetes_cluster_node_pool" "wind_apps" {
  name                  = "wapps"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_DS2_v2"
  orchestrator_version = azurerm_kubernetes_cluster.main.kubernetes_version
  zones                 = [1, 2, 3]
  min_count             = 1
  max_count             = 3
  os_disk_size_gb       = 90
  os_type               = "Windows"
  enable_auto_scaling   = true
  node_labels = {
    "node-pool" = "user"
    "env"       = "prd"
    "type"      = "windows"
  }
  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "monitoring" {
  name                  = "linuxapps"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_DS2_v2"
  orchestrator_version = azurerm_kubernetes_cluster.main.kubernetes_version
  zones                 = [1, 2, 3]
  min_count             = 1
  max_count             = 3
  os_disk_size_gb       = 90
  os_type               = "Linux"
  enable_auto_scaling   = true
  node_labels = {
    "node-pool" = "monitoring"
    "env"       = "prd"
    "type"      = "linux"
  }
  tags = var.tags
}