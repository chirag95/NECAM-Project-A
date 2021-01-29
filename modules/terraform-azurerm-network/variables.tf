variable "vnet_name_suffix" {
  description = "Name of the vnet to create."
  type        = string
  default     = ""
}

variable "resource_group_name" {
  description = "The name of an existing resource group to be imported."
  type        = string
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
  description = "Region is which aks will be created."
  type = string
}

variable "address_space" {
  description = "The address space that is used by the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

# If no values specified, this defaults to Azure DNS 
variable "dns_servers" {
  description = "The DNS servers to be used with vNet."
  type        = list(string)
  default     = []
}

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "subnet_name_suffix" {
  description = "Suffix to add at the end of auto calculated subnet name"
  type        = string
  default     = ""
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)

  default = {
    environment = "dev"
  }
}

variable "ddos_plan_name_suffix" {
  description = "Name suffix of the ddos plan"
  type        = string
  default     = ""
}

variable "create_ddos_plan" {
  description = "Option to create an ddos plan"
  type        = bool
  default     = false
}

variable "ddos_resource_tags" {
  description = "Additional(optional) tags for ddos plan"
  type        = map(string)
  default     = {}
}

variable "bastion_config" {
  description = "Map presenting a bastion's data"
  type = object({
    enable                              = bool,
    azure_bastion_service_name_suffix   = string,
    azure_bastion_subnet_address_prefix = list(string),
    public_ip_allocation_method         = string,
    public_ip_sku                       = string,
    domain_name_label                   = string,
    tags                                = map(string)
  })
}

variable "firewall_config" {
  description = "Map presenting a firewall's data"
  type = object({
    enable                      = bool,
    suffix                      = string,
    tags                        = map(string),
    subnet_address_prefix       = string,
    public_ip_sku               = string,
    public_ip_allocation_method = string
  })
}
