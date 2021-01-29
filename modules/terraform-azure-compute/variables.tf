variable "environment" {
  description = "Project environment"
  type        = string
}

variable "stack" {
  description = "Project stack name"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created."
  type        = string
}

variable "location" {
  description = "(Optional) The location in which the resources will be created."
  type        = string
  default     = ""
}

variable "vnet_subnet_id" {
  description = "The subnet id of the virtual network where the virtual machines will reside."
  type        = string
}

variable "public_ip_dns" {
  description = "Optional globally unique per datacenter region domain name label to apply to each public ip address. e.g. thisvar.varlocation.cloudapp.azure.com where you specify only thisvar here. This is an array of names which will pair up sequentially to the number of public ips defined in var.nb_public_ip. One name or empty string is required for every public ip. If no public ip is desired, then set this to an array with a single empty string."
  type        = list(string)
  default     = [null]
}

variable "admin_password" {
  description = "The admin password to be used on the VMSS that will be deployed. The password must meet the complexity requirements of Azure."
  type        = string
  default     = ""
}

variable "ssh_key" {
  description = "Path to the public key to be used for ssh access to the VM.  Only used with non-Windows vms and can be left as-is even if using Windows vms. If specifying a path to a certification on a Windows machine to provision a linux vm use the / in the path versus backslash. e.g. c:/home/id_rsa.pub."
  type        = string
  default     = ""
}

variable "generate_admin_ssh_key" {
  description = "Generates a secure private key and encodes it as PEM."
  default     = true
}

variable "nsg_rules" {
  type = map(map(string))
  default = {
    allow_ssh = {
      priority         = 100
      protocol         = "TCP"
      destination_port = "*"
      source_address   = "10.0.0.0/8"
      access           = "Allow"
      direction        = "Inbound"
    }
  }
}

variable "admin_username" {
  description = "The admin username of the VM that will be deployed."
  type        = string
  default     = "azureuser"
}

variable "custom_data" {
  description = "The custom data to supply to the machine. This can be used as a cloud-init for Linux systems."
  type        = string
  default     = ""
}

variable "storage_account_type" {
  description = "Defines the type of storage account to be created. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  type        = string
  default     = "Premium_LRS"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "nb_instances" {
  description = "Specify the number of vm instances."
  type        = number
  default     = 1
}

variable "vm_hostname" {
  description = "local name of the Virtual Machine."
  type        = string
  default     = "myvm"
}

variable "vm_os_simple" {
  description = "Specify UbuntuServer, WindowsServer, RHEL, openSUSE-Leap, CentOS, Debian, CoreOS and SLES to get the latest image version of the specified os.  Do not provide this value if a custom value is used for vm_os_publisher, vm_os_offer, and vm_os_sku."
  type        = string
  default     = ""
}

variable "vm_os_id" {
  description = "The resource ID of the image that you want to deploy if you are using a custom image.Note, need to provide is_windows_image = true for windows custom images."
  type        = string
  default     = ""
}

variable "is_windows_image" {
  description = "Boolean flag to notify when the custom image is windows based."
  type        = bool
  default     = false
}

variable "vm_os_publisher" {
  description = "The name of the publisher of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  type        = string
  default     = ""
}

variable "vm_os_offer" {
  description = "The name of the offer of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  type        = string
  default     = ""
}

variable "vm_os_sku" {
  description = "The sku of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  type        = string
  default     = ""
}

variable "vm_os_version" {
  description = "The version of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  type        = string
  default     = "latest"
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}

variable "public_ip_allocation_method" {
  description = "Defines how an IP address is assigned. Options are Static or Dynamic."
  type        = string
  default     = "Dynamic"
}

variable "nb_public_ip" {
  description = "Number of public IPs to assign corresponding to one IP per vm. Set to 0 to not assign any public IP addresses."
  type        = number
  default     = 1
}

variable "public_ip_sku" {
  description = "The SKU of the VM public IP. Accepted values are Basic and Standard."
  default     = "Standard"
}

variable "private_ips_cidrhost_prefix" {
  description = "Cidrhost prefix for calculating private ips for vm"
}

variable "last_hostnum" {
  description = "Last hostnum for calculating private ips for vm"
  type = number
}

variable "delete_os_disk_on_termination" {
  type        = bool
  description = "Delete os disk when machine is terminated."
  default     = false
}

variable "delete_data_disk_on_termination" {
  type        = bool
  description = "Delete datadisk when machine is terminated."
  default     = false
}

variable "storage_data_disk" {
  description = "A list of Storage Data disk blocks"
  type = any
  default = [{
      create_option     = "Empty" #(Required) Possible values are Attach, FromImage and Empty.
      disk_size_gb      = 30  #(Required) Specifies the size of the data disk in gigabytes.
      managed_disk_type = "Standard_LRS"  #Value must be either Standard_LRS or Premium_LRS.
  }]
}

variable "boot_diagnostics" {
  type        = bool
  description = "(Optional) Enable or Disable boot diagnostics."
  default     = false
}

variable "boot_diagnostics_sa_type" {
  description = "(Optional) Storage account type for boot diagnostics."
  type        = string
  default     = "Standard_LRS"
}

variable "enable_accelerated_networking" {
  type        = bool
  description = "(Optional) Enable accelerated networking on Network interface."
  default     = false
}

variable "enable_ssh_key" {
  type        = bool
  description = "(Optional) Enable ssh key authentication in Linux virtual Machine."
  default     = true
}

variable "source_address_prefixes" {
  description = "(Optional) List of source address prefixes allowed to access var.remote_port."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "license_type" {
  description = "Specifies the BYOL Type for this Virtual Machine. This is only applicable to Windows Virtual Machines. Possible values are Windows_Client and Windows_Server"
  type        = string
  default     = null
}

variable "identity_type" {
  description = "The Managed Service Identity Type of this Virtual Machine."
  type        = string
  default     = ""
}

variable "identity_ids" {
  description = "Specifies a list of user managed identity ids to be assigned to the VM."
  type        = list(string)
  default     = []
}

variable "create_availability_set" {
  description = "Whether to create availability set or not."
  type        = bool
  default     = false
}

variable "availability_set_config" {
  description = "Configuration for availability set to be created"
  type = object({
    platform_fault_domain_count    = number
    platform_update_domain_count   = number
    managed                        = bool
    tags                           = map(string)
  })

}

variable "lb_prefix" {}
variable "lb_sku" {}
variable "enable_load_balancer" {}
variable "lb_type" {}
variable "lb_probe_unhealthy_threshold" {}
variable "lb_probe_interval" {}
variable "lb_allocation_method" {}
variable "lb_tags" {}
variable "lb_frontend_private_ip_address" {}
variable "lb_frontend_private_ip_address_allocation" {}
variable "lb_public_ip_sku" {}
variable "lb_remote_port" {}
variable "lb_port" {}
variable "lb_probe" {}
variable "lb_ipv4_tags" {}
variable "enable_floating_ip" {}

#backup variables
variable "enable_vm_backup" {
  description = "Enable VM backup or not"
  type        = bool
  default     = false
}

variable "recovery_vault_sku" {
  description = "Sku of the recovery_services_vault to be created"
  default     = "Standard"
}

variable "backup_recovery_vault_name_suffix" {
  description = "Backup recovery vault name"
  type        = string
}

variable "timezone" {
  description = "(Optional) Specifies the timezone. Defaults to UTC"
  type        = string
  default     = "UTC"
}

variable "vm_backup" {
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

#Auto shutdown variables
variable "enable_autoshutdown" {
  description = "Enable autoshutdown for VM"
  type = bool
  default = false
}

variable "daily_recurrence_time" {
  description = "(Required) The time each day when the schedule takes effect. Must match the format HHmm where HH is 00-23 and mm is 00-59 (e.g. 0930, 2300, etc.)"
  type = string
  default = "1100"
}

variable "VM_shutdown_timezone" {
  description = "(Required) The time zone ID (e.g. Pacific Standard time)."
  type = string
  default = "UTC"
}

variable "notification_settings" {
  description = "Block supports: enabled, time_in_minutes and webhook_url"
  type = any
  default = {
    enabled         = true  #(Optional) Whether to enable pre-shutdown notifications. Possible values are true and false. Defaults to false.
    time_in_minutes = "60"  #(Optional) Time in minutes between 15 and 120 before a shutdown event at which a notification will be sent. Defaults to 30.
    webhook_url     = "https://sample-webhook-url.example.com"   #The webhook URL to which the notification will be sent. Required if enabled is true. Optional otherwise.
  }
}

# OS diagnostics
variable "configuration_json" {
  default = "{\"diagnosticMonitorConfiguration\":{\"metrics\":{\"resourceId\":\"%VirtualMachineResourceId%\",\"metricAggregation\":[{\"scheduledTransferPeriod\":\"PT1H\"},{\"scheduledTransferPeriod\":\"PT1M\"}]},\"performanceCounters\":{\"performanceCounterConfiguration\":[{\"class\":\"Memory\",\"counterSpecifier\":\"PercentAvailableMemory\",\"table\":\"LinuxMemory\"},{\"class\":\"Memory\",\"counterSpecifier\":\"AvailableMemory\",\"table\":\"LinuxMemory\"},{\"class\":\"Memory\",\"counterSpecifier\":\"UsedMemory\",\"table\":\"LinuxMemory\"},{\"class\":\"Memory\",\"counterSpecifier\":\"PercentUsedSwap\",\"table\":\"LinuxMemory\"},{\"class\":\"Processor\",\"counterSpecifier\":\"PercentProcessorTime\",\"table\":\"LinuxCpu\"},{\"class\":\"Processor\",\"counterSpecifier\":\"PercentIOWaitTime\",\"table\":\"LinuxCpu\"},{\"class\":\"Processor\",\"counterSpecifier\":\"PercentIdleTime\",\"table\":\"LinuxCpu\"},{\"class\":\"PhysicalDisk\",\"counterSpecifier\":\"AverageWriteTime\",\"table\":\"LinuxDisk\"},{\"class\":\"PhysicalDisk\",\"counterSpecifier\":\"AverageReadTime\",\"table\":\"LinuxDisk\"},{\"class\":\"PhysicalDisk\",\"counterSpecifier\":\"ReadBytesPerSecond\",\"table\":\"LinuxDisk\"},{\"class\":\"PhysicalDisk\",\"counterSpecifier\":\"WriteBytesPerSecond\",\"table\":\"LinuxDisk\"}]}}}"
}

variable "os_diagnostics_storage_account_type" {
  description = "Defines the type of storage account to be created for OS diagnostics. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  type        = string
  default     = "Standard_LRS"
}

variable "enable_os_diagnostics" {
  description = "Enable OS diagnostics."
  type = bool
  default = false
}