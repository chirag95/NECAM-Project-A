variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = ""
}

variable "environment" {
  description = "Project environment"
  type        = string
}

variable "stack" {
  description = "Project stack name"
  type        = string
}

variable "location" {
  description = "Region is which resources will be created."
  type = string
  default = null
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  default     = ""
}

variable "public_ip_allocation_method" {
  description = "Defines the allocation method for this IP address. Possible values are Static or Dynamic"
  default     = "Static"
}

variable "public_ip_sku" {
  description = "The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic"
  default     = "Standard"
}

variable "azure_firewall_subnet_address_prefix" {
  description = "The address prefix to use for the Azure firewall subnet"
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "firewall_suffix" {
  description = "The suffix of the firewall."
  default     = ""
}
