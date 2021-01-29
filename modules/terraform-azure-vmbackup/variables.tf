variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Region is which resources will be created."
  type = string
  default = null
}

variable "environment" {
  description = "Project environment"
  type        = string
}

variable "stack" {
  description = "Project stack name"
  type        = string
}

variable "recovery_vault_sku" {
  description = "Sku of the recovery_services_vault to be created"
  default     = "Standard"
}

variable "vm_ids" {
  description = "List of Azure VM ID to attach to the Backup policy"
  type        = any
}

variable "vm_count" {
  description = "Number of Azure vm to attach to the Backup policy"
  type        = number
}

variable "recovery_vault_name_suffix" {
  description = "Backup recovery vault name"
  type        = string
}

variable "timezone" {
  description = "(Optional) Specifies the timezone. Defaults to UTC"
  type        = string
  default     = "UTC"
}

variable "backup" {
  description = "Configures the Policy backup frequency, times & days"
  type        = any
  default = {
    frequency = "Daily" #(Required) Sets the backup frequency. Must be either Daily or Weekly.
    time      = "23:00" #(Required) The time of day to perform the backup in 24hour format.
    #weekdays = ["Sunday"]    #(Optional) The days of the week to perform backups on.
  }
}

variable "retention_daily_count" {
  description = "The number of daily backups to keep. Must be between 7 and 9999. Required when backup frequency is Daily."
  type        = number
  default     = 7
}

variable "retention_weekly" {
  description = "(Optional) Configures the policy weekly retention. Required when backup frequency is Weekly"
  type        = any
  default = {
    count    = 42                                            #The number of weekly backups to keep. Must be between 1 and 9999
    weekdays = ["Sunday", "Wednesday", "Friday", "Saturday"] #The weekday backups to retain. Must be one of Sunday, Monday, Tuesday, Wednesday, Thursday, Friday or Saturday.
  }
}

variable "retention_monthly" {
  description = "(Optional) Configures the policy monthly retention. Required when backup frequency is monthly"
  type        = any
  default = {
    count    = 7
    weekdays = ["Sunday", "Wednesday"]
  weeks = ["First", "Last"] }
}

variable "retention_yearly" {
  description = "(Optional) Configures the policy yearly retention. Required when backup frequency is yearly"
  type        = any
  default = {
    count    = 77
    weekdays = ["Sunday"]
    weeks    = ["Last"]
    months   = ["January"]
  }
}
