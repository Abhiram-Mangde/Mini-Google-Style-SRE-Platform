resource "azurerm_resource_group" "example" {
  name     = var.resource_group
  location = var.location
}

# ---------------------------
# Azure Container Registry
# ---------------------------
resource "azurerm_container_registry" "example" {
  name                = "sredocker97514"
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
    Environment = "Production"
  }
}
# -----------------------
# Kubernetes Secret 
#-----------------------
resource "kubernetes_secret" "acr" {
  metadata {
    name      = "acr-secret"
    namespace = "default"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
          "auths": {
            "${azurerm_container_registry.example.login_server}" ={
              auth = base64encode("${azurerm_container_registry.example.admin_username}:${azurerm_container_registry.example.admin_password}")
            }
          }
        }
      )}
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
  name                     = "srestorageaccount15240"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}