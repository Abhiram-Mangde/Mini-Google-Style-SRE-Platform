resource "azurerm_resource_group" "example" {
  name     = var.resource_group
  location = var.location
}

# --------------------------
# Random Numbers 
#---------------------------
resource "random_integer" "ri" {
  min = 6
  max = 100
}

# ---------------------------
# Azure Container Registry
# ---------------------------
resource "azurerm_container_registry" "example" {
  name                = "sreacregistry135790631"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"
  admin_enabled       = true
}

# ---------------------------
# AKS Cluster
# ---------------------------
resource "azurerm_kubernetes_cluster" "example" {
  name                = var.aks
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_A2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id
  }

  tags = {
    Environment = var.environment
  }
}

# ---------------------------
# Log Analytics
# ---------------------------
resource "azurerm_log_analytics_workspace" "la" {
  name                = var.la
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
}

# ---------------------------
# Storage Account
# ---------------------------
resource "azurerm_storage_account" "example" {
  name                     = "${var.prefix}storage${random_integer.ri.result}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = var.environment
  }
}