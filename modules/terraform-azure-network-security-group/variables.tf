variable "location" {
  description = "Azure location."
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

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "name_prefix" {
  description = "Optional prefix for Network Security Group name"
  type        = string
  default     = ""
}

variable "custom_network_security_group_names" {
  description = "List of Network Security Group custom names."
  type        = list(string)
  default     = [""]
}

variable "extra_tags" {
  description = "Additional tags to associate with your Network Security Group."
  type        = map(string)
  default     = {}
}

variable "network_security_group_instances" {
  description = "Number of Network Security Group to create."
  type        = number
  default     = 1
}
