variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created."
  type        = string
}

variable "location" {
  description = "Region is which resources will be created."
  type = string
  default = null
}

variable "name" {
  default = "sample-avset"
}

variable "platform_fault_domain_count" {
  description = "The number of fault domains that are to be used."
  type        = number
  default     = 2
}

variable "platform_update_domain_count" {
  description = "The number of update domains that are used."
  type        = number
  default     = 2
}

variable "managed" {
  description = " Whether the availability set is managed or not."
  type        = bool
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."
  default     = {}
}