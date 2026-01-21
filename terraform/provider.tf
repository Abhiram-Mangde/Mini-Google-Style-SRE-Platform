terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Kubernetes provider connects to AKS
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.example.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.example.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.example.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config[0].cluster_ca_certificate)
}