variable "environment" {
  description = "Project environment"
  type        = string
}

variable "stack" {
  description = "Project stack name"
  type        = string
}

variable "create_resource_group" {
  type    = bool
  default = true
}

variable "location" {
  description = "Resource Group Location"
  default     = "West US"
}

variable "name" {
  description = "Resource Group Name"
}

variable "tags" {
  description = "Tags for the resource group(like {environment = 'dev'})"
}
