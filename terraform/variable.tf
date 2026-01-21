variable "prefix" {
  description = "Prefix to be added to resource names"
  type        = string
  default     = "sreplatform"
}

variable "resource_group" {
  type    = string
  default = "t_SrePlatform_ResourceGroup"
}

variable "location" {
  type    = string
  default = "West Europe"
}

variable "aks" {
  default = "sreakscluster"
}

variable "la" {
  default = "SreLogAnalytic"
}

variable "environment" {
  default = "Production"
}