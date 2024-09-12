variable "node_count" {
  default = 1
}

variable "container_registry_name" {
  default = "iisdevopsprojectcontainerregistry"
}

variable "cluster_name" {
  default = "iis-devops-project-aks-cluster"
}

variable "dns_prefix" {
  default = "iis-aks"
}

variable "resource_group_location" {
  default     = "eastus2"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  default     = "iis-devops-project-rg"
  description = "Name of the Azure resource group that the AKS cluster will exist within."
}

// Path to the public key used for authN with the AKS cluster (using local path for demo, but should be pulled in via CD pipeline)
variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}