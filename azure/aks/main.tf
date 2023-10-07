terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.75.0"
    }
  }
}
provider "azurerm" {
  features {}
}

variable "tags" {
  type = map(string)
  default = {
    TEAM  = "GK",
    STACK = "webtier",
    OU    = "SRE"
  }
}

# 0. Create a RG
module "resource_group" {
  source              = "github.com/raildsonf/terraform-modules.git//azure/resource-group?ref=main"
  resource_group_name = "main"
  location            = "East US"
  tags                = var.tags
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
  scope                = "/subscriptions/4777093f-e44b-4d8d-9b6d-e28ad6dda062"
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
    "List",
    "Purge"
  ]
  key_permissions = [
    "Delete",
    "Get",
    "List"
  ]
  storage_permissions = [
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
  depends_on = [ azurerm_key_vault_access_policy.main ]
}

# 3. Create the AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = "conta-digital"
  kubernetes_version  = "1.27.3"
  location            = "East US"
  resource_group_name = "main"
  dns_prefix          = "conta-digital"
  oidc_issuer_enabled = true

  default_node_pool {
    name                = "default"
    zones               = [1, 2, 3]
    vm_size             = "Standard_D2_v2"
    min_count           = 1
    max_count           = 3
    os_disk_size_gb     = 90
    enable_auto_scaling = true
    type                = "VirtualMachineScaleSets"
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
  depends_on = [azurerm_role_assignment.main, module.resource_group]
}

# 4. Create Node Pools
resource "azurerm_kubernetes_cluster_node_pool" "wind_apps" {
  name                  = "wapps"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_DS2_v2"
  orchestrator_version  = azurerm_kubernetes_cluster.main.kubernetes_version
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
  tags       = var.tags
  depends_on = [azurerm_kubernetes_cluster.main]
}

resource "azurerm_kubernetes_cluster_node_pool" "monitoring" {
  name                  = "linuxapps"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_DS2_v2"
  orchestrator_version  = azurerm_kubernetes_cluster.main.kubernetes_version
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
  tags       = var.tags
  depends_on = [azurerm_kubernetes_cluster.main]
}

# 5. Install FluxCD
data "azurerm_kubernetes_cluster" "credentials" {
  name                = azurerm_kubernetes_cluster.main.name
  resource_group_name = "main"
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.credentials.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.cluster_ca_certificate)

  }
}
resource "helm_release" "fluxcd" {
  name = "flux"
  namespace = "flux-system"
  create_namespace = true
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2"
  values = [
    "${file("values.yaml")}"
  ]
}