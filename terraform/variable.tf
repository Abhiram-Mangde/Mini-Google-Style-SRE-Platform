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