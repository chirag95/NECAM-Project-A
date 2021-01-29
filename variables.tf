variable "project_name" {
}

variable "environment" {
}

variable "common_resource_location" {
  description = "Region is which resources other than resource group will be created. If set to null, created in the region where resource group is situated."
  type = string
  default = null
}

variable "common_tags" {
  description = "Common tags for all resources."
  type = map(string)
}

variable "subscription_id" {
  description = "Subscription id to be used for resources."
}

variable "tenant_id" {
  description = "Tenant id to be used for resources."
}

variable "client_id" {
  description = "Client id to be used for resource creation."
}

variable "client_secret" {
  description = "Client secret to be used for resources creation."
}
#-----------------------------
#  Module: Resource Group
#-----------------------------

  variable "use_existing_resource_group" {
    type    = bool
    default = false
  }

  variable "region" {
    description = "Resource Group Location"
    type        = string
    default     = "eastus"
  }

  variable "resource_group_name" {
    description = "Resource Group Name"
    type        = string
    default     = "sample-resgp"
  }

  variable "resource_group_tags" {
    description = "Tags for the resource group(like {environment = 'dev'})"
    type        = map(string)
    default = {
      environment = "dev"
    }
  }



#-----------------------------
#  Module: Network
#-----------------------------

  variable "network_location" {
    description = "Region is which network will be created. If set to null, network will be created in the region where resource group is situated."
    type = string
    default = null
  }

  variable "vnet_name_suffix" {
    description = "Name suffix of the virtual network to create."
    type        = string
    default     = ""
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
    default     = ["10.0.1.0/24", "10.0.2.0/24"]
  }

  variable "subnet_name_suffix" {
    description = "Suffix to add at the end of auto calculated subnet name"
    type        = string
    default     = ""
  }
  # variable "subnet_names" {
  #   description = "A list of public subnets inside the vNet."
  #   type        = list(string)
  #   default     = ["subnet1", "subnet2"]
  # }

  variable "vnet_tags" {
    description = "The tags to associate with your network and subnets."
    type        = map(string)
    default = {
      environment = "dev"
    }
  }

  variable "ddos_plan_name_suffix" {
    description = "Suffix for name of the ddos plan"
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
    default     = { environment = "dev" }
  }

  #------- Bastion Host variables
  variable "enable_bastion" {
    description = "Enable bastion host for the virtual network?"
    type        = bool
    default     = true
  }

  variable "azure_bastion_service_name_suffix" {
    description = "The suffix for the name of the Bastion Host"
    type        = string
    default     = ""
  }

  variable "azure_bastion_subnet_address_prefix" {
    description = "The address prefix to use for the Azure Bastion subnet"
    default     = []
  }

  variable "public_ip_allocation_method" {
    description = "Defines the allocation method for this IP address. Possible values are Static or Dynamic"
    default     = "Static"
  }

  variable "public_ip_sku" {
    description = "The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic"
    default     = "Standard"
  }

  variable "bastion_domain_name_label" {
    description = "Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system"
    default     = null
  }

  variable "bastion_tags" {
    description = "A map of tags to add to all resources"
    type        = map(string)
    default     = {}
  }

  # firewall variables

  variable "enable_firewall_for_vnet" {
    description = "Enable bastion host for the virtual network?"
    type        = bool
  }

  # variable "firewall_public_ip_name" {
  #   description = "Name of the public IP if it already exists for use."
  #   type        = string
  #   default     = ""
  # }

  variable "firewall_public_ip_allocation_method" {
    description = "Defines the allocation method for this IP address. Possible values are Static or Dynamic. Used only if public_ip not defined."
    default     = "Static"
  }

  variable "firewall_public_ip_sku" {
    description = "The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic. Used only if public_ip not defined."
    default     = "Standard"
  }

  variable "azure_firewall_subnet_address_prefix" {
    description = "The address prefix to use for the Azure firewall subnet"
    default     = ""
  }

  variable "firewall_tags" {
    description = "A map of tags to add to all resources"
    type        = map(string)
    default     = {}
  }

  variable "firewall_suffix" {
    description = "The suffix of the firewall."
    default     = ""
  }

#-----------------------------
#  Module: Compute
#-----------------------------

  variable "vm_config" {
    description = "List of configuration for VMs."
    type = any
  }
  # variable "vm_location" {
  #   description = "Region is which vm's will be created. If set to null, vm's will be created in the region where resource group is situated."
  #   type = string
  #   default = null
  # }

  # variable "vnet_subnet_index" {
  #   description = "Index of the subnet of the virtual network created where the virtual machines will reside.(example: 0)"
  #   type        = number
  #   default     = 0
  # }

  # variable "public_ip_dns" {
  #   description = "Optional globally unique per datacenter region domain name label to apply to each public ip address. e.g. thisvar.varlocation.cloudapp.azure.com where you specify only thisvar here. This is an array of names which will pair up sequentially to the number of public ips defined in var.nb_public_ip. One name or empty string is required for every public ip. If no public ip is desired, then set this to an array with a single empty string."
  #   type        = list(string)
  #   default     = [null]
  # }

  # variable "admin_password" {
  #   description = "The admin password to be used on the VM's that will be deployed. The password must meet the complexity requirements of Azure."
  #   type        = string
  #   default     = "Nec@123"
  # }

  # variable "ssh_key" {
  #   description = "Path to the public key to be used for ssh access to the VM.  Only used with non-Windows vms and can be left as-is even if using Windows vms. If specifying a path to a certification on a Windows machine to provision a linux vm use the / in the path versus backslash. e.g. c:/home/id_rsa.pub."
  #   type        = string
  #   default     = ""
  # }

  # # variable "remote_port" {
  # #   description = "Remote tcp ports to be used for access to the vms created via the nsg applied to the nics."
  # #   type        = list(string)
  # #   default     = []
  # # }

  # variable "nsg_rules" {
  #   type = map(map(string))
  #   default = {
  #     allow_ssh = {
  #       priority         = 100
  #       protocol         = "TCP"
  #       destination_port = "22"
  #       source_address   = "10.0.0.0/8"
  #       access           = "Allow"
  #       direction        = "Inbound"
  #     }

  #   }
  # }

  # variable "admin_username" {
  #   description = "The admin username of the VM that will be deployed."
  #   type        = string
  #   default     = "azureuser"
  # }

  # variable "custom_data" {
  #   description = "The custom data to supply to the machine. This can be used as a cloud-init for Linux systems."
  #   type        = string
  #   default     = ""
  # }

  # variable "storage_account_type" {
  #   description = "Defines the type of storage account to be created. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  #   type        = string
  #   default     = "Premium_LRS"
  # }

  # variable "vm_size" {
  #   description = "Specifies the size of the virtual machine."
  #   type        = string
  #   default     = "Standard_B2s"
  # }

  # variable "nb_instances" {
  #   description = "Specify the number of vm instances."
  #   type        = number
  #   default     = 1
  # }

  # variable "vm_hostname" {
  #   description = "local name of the Virtual Machine."
  #   type        = string
  #   default     = "myvm"
  # }

  # variable "vm_os_simple" {
  #   description = "Specify UbuntuServer, WindowsServer, RHEL, openSUSE-Leap, CentOS, Debian, CoreOS and SLES to get the latest image version of the specified os.  Do not provide this value if a custom value is used for vm_os_publisher, vm_os_offer, and vm_os_sku."
  #   type        = string
  #   default     = "CentOS"
  # }

  # variable "vm_os_id" {
  #   description = "The resource ID of the image that you want to deploy if you are using a custom image.Note, need to provide is_windows_image = true for windows custom images."
  #   type        = string
  #   default     = ""
  # }

  # variable "is_windows_image" {
  #   description = "Boolean flag to notify when the custom image is windows based."
  #   type        = bool
  #   default     = false
  # }

  # variable "vm_os_publisher" {
  #   description = "The name of the publisher of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  #   type        = string
  #   default     = ""
  # }

  # variable "vm_os_offer" {
  #   description = "The name of the offer of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  #   type        = string
  #   default     = ""
  # }

  # variable "vm_os_sku" {
  #   description = "The sku of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  #   type        = string
  #   default     = ""
  # }

  # variable "vm_os_version" {
  #   description = "The version of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  #   type        = string
  #   default     = "latest"
  # }

  # variable "vm_tags" {
  #   type        = map(string)
  #   description = "A map of the tags to use on the resources that are deployed with this module."

  #   default = {
  #     source = "terraform"
  #   }
  # }

  # variable "vm_public_ip_allocation_method" {
  #   description = "Defines how an IP address is assigned. Options are Static or Dynamic."
  #   type        = string
  #   default     = "Static"
  # }

  # variable "vm_nb_public_ip" {
  #   description = "Number of public IPs to assign corresponding to one IP per vm. Set to 0 to not assign any public IP addresses."
  #   type        = number
  #   default     = 1
  # }

  # variable "vm_public_ip_sku" {
  #   description = "The SKU of the VM public IP. Accepted values are Basic and Standard."
  #   default     = "Standard"
  # }

  # variable "private_ips" {
  #   description = "Static private IPs to assign corresponding to one IP per vm."
  #   type        = list(string)
  # }

  # variable "delete_os_disk_on_termination" {
  #   type        = bool
  #   description = "Delete os disk when machine is terminated."
  #   default     = false
  # }

  # variable "delete_data_disk_on_termination" {
  #   type        = bool
  #   description = "Delete datadisk when machine is terminated."
  #   default     = false
  # }

  # variable "storage_data_disk" {
  #   description = "A list of Storage Data disk blocks"
  #   type        = any
  #   default = [{
  #     create_option     = "Empty"        #(Required) Possible values are Attach, FromImage and Empty.
  #     disk_size_gb      = 30             #(Required) Specifies the size of the data disk in gigabytes.
  #     managed_disk_type = "Standard_LRS" #Value must be either Standard_LRS or Premium_LRS.
  #   }]
  # }
  # # variable "data_sa_type" {
  # #   description = "Data Disk Storage Account type."
  # #   type        = string
  # #   default     = "Standard_LRS"
  # # }

  # # variable "data_disk_size_gb" {
  # #   description = "Storage data disk size size."
  # #   type        = number
  # #   default     = 30
  # # }

  # variable "boot_diagnostics" {
  #   type        = bool
  #   description = "(Optional) Enable or Disable boot diagnostics."
  #   default     = false
  # }

  # variable "boot_diagnostics_sa_type" {
  #   description = "(Optional) Storage account type for boot diagnostics."
  #   type        = string
  #   default     = "Standard_LRS"
  # }

  # variable "enable_accelerated_networking" {
  #   type        = bool
  #   description = "(Optional) Enable accelerated networking on Network interface."
  #   default     = false
  # }

  # variable "enable_ssh_key" {
  #   type        = bool
  #   description = "(Optional) Enable ssh key authentication in Linux virtual Machine."
  #   default     = false
  # }

  # variable "generate_admin_ssh_key" {
  #   description = "Generates a secure private key and encodes it as PEM."
  #   default     = true
  # }

  # # variable "nb_data_disk" {
  # #   description = "(Optional) Number of the data disks attached to each virtual machine."
  # #   type        = number
  # #   default     = 0
  # # }

  # variable "source_address_prefixes" {
  #   description = "(Optional) List of source address prefixes allowed to access var.remote_port."
  #   type        = list(string)
  #   default     = ["0.0.0.0/0"]
  # }

  # variable "license_type" {
  #   description = "Specifies the BYOL Type for this Virtual Machine. This is only applicable to Windows Virtual Machines. Possible values are Windows_Client and Windows_Server"
  #   type        = string
  #   default     = null
  # }

  # variable "identity_type" {
  #   description = "The Managed Service Identity Type of this Virtual Machine."
  #   type        = string
  #   default     = ""
  # }

  # variable "identity_ids" {
  #   description = "Specifies a list of user managed identity ids to be assigned to the VM."
  #   type        = list(string)
  #   default     = []
  # }

  # #------------Availability set variables-----------------

  # variable "create_availability_set" {
  #   description = "Whether to create availability set or not."
  #   type        = bool
  #   default     = false
  # }

  # variable "av_set_platform_fault_domain_count" {
  #   description = "The number of fault domains that are to be used for availability set."
  #   type        = number
  #   default     = 2
  # }

  # variable "av_set_platform_update_domain_count" {
  #   description = "The number of update domains that are used for availability set."
  #   type        = number
  #   default     = 2
  # }

  # variable "av_set_managed" {
  #   description = " Whether the availability set is managed or not."
  #   type        = bool
  #   default     = true
  # }

  # variable "av_set_tags" {
  #   type        = map(string)
  #   description = "A map of the tags to use on the availibility sets."
  #   default     = {}
  # }

  # variable "proximity_placement_group_name" {
  #   description = "Name of the proximity placement group to be created"
  # }

  # #----------loadbalancer variables-------------------

  # variable "loadbalancer_prefix" {
  #   description = "The prefix to be given to load balancer"
  #   default     = ""
  # }
  # variable "load_balancer_sku" {
  #   description = "The SKU of the Azure Load Balancer. Accepted values are Basic and Standard."
  #   default     = "Standard"
  # }

  # variable "enable_load_balancer" {
  #   description = "Controls if public load balancer should be created"
  #   default     = true
  # }

  # variable "load_balancer_type" {
  #   description = "Controls the type of load balancer should be created. Possible values are public and private"
  #   default     = "private"
  # }

  # variable "lb_remote_port" {
  #   description = "Protocols to be used for remote vm access. [protocol, backend_port].  Frontend port will be automatically generated starting at 50000 and in the output."
  #   type        = map(any)
  #   default     = {}
  # }

  # variable "lb_port" {
  #   description = "Protocols to be used for lb rules. Format as [frontend_port, protocol, backend_port]"
  #   type        = map(any)
  #   default     = {}
  # }

  # variable "lb_probe" {
  #   description = "(Optional) Protocols to be used for lb health probes. Format as [protocol, port, request_path]"
  #   type        = map(any)
  #   default     = {}
  # }

  # variable "lb_probe_unhealthy_threshold" {
  #   description = "Number of times the load balancer health probe has an unsuccessful attempt before considering the endpoint unhealthy."
  #   type        = number
  #   default     = 2
  # }

  # variable "lb_probe_interval" {
  #   description = "Interval in seconds the load balancer health probe rule does a check"
  #   type        = number
  #   default     = 5
  # }

  # # variable "lb_frontend_name_suffix" {
  # #   description = "Specifies the name suffix of the frontend ip configuration."
  # #   type        = string
  # #   default     = "myPublicIP"
  # # }

  # variable "lb_allocation_method" {
  #   description = "(Required) Defines how an IP address is assigned. Options are Static or Dynamic."
  #   type        = string
  #   default     = "Static"
  # }

  # variable "lb_tags" {
  #   type = map(string)

  #   default = {
  #     source = "terraform"
  #   }
  # }

  # variable "lb_frontend_private_ip_address" {
  #   description = "(Optional) Private ip address to assign to frontend. Use it with type = private"
  #   type        = string
  #   default     = ""
  # }

  # variable "lb_frontend_private_ip_address_allocation" {
  #   description = "(Optional) Frontend ip allocation type (Static or Dynamic)"
  #   type        = string
  #   default     = "Dynamic"
  # }

  # variable "lb_public_ip_sku" {
  #   description = "The SKU of the Azure Load Balancer. Accepted values are Basic and Standard."
  #   default     = "Standard"
  # }

  # variable "lb_ipv4_tags" {
  #   type = map(string)

  #   default = {
  #     source = "terraform"
  #   }
  # }

  # variable "enable_floating_ip" {
  #   description = "Enable floating ip or not"
  #   default     = false
  # }

  # # # variables for ipv6
  # # variable "lb_use_public_ipv6" {
  # #   type    = bool
  # #   default = false
  # # }

  # # # The following variables are used only if use_ipv6 == true
  # # variable "lb_ipv6_tags" {
  # #   type = map(string)

  # #   default = {
  # #     source = "terraform"
  # #   }
  # # }

  # # variable "lb_public_ipv6_sku" {
  # #   description = "The SKU of the Azure Load Balancer. Accepted values are Basic and Standard."
  # #   default     = "Standard"
  # # }

  # # variable "lb_enable_floating_ipv6" {
  # #   description = "Enable floating ip or not"
  # #   default     = false
  # # }

  # # variable "lb_ipv6_allocation_method" {
  # #   description = "(Required) Defines how an IP v6 address is assigned. Options are Static or Dynamic."
  # #   type        = string
  # #   default     = "Static"
  # # }

  # # # variable "public_lb_frontend_ip_v6_configuration_name" {
  # # #   description = "(Required) Specifies the name of the frontend ipv6  configuration."
  # # #   type        = string
  # # #   default     = "myPublicIPv6"
  # # # }

  # # variable "lb_frontend_private_ipv6_address_allocation" {
  # #   description = "(Optional) Frontend ip allocation type (Static or Dynamic)"
  # #   type        = string
  # #   default     = "Dynamic"
  # # }

  # # variable "lb_port_ipv6" {
  # #   description = "Protocols to be used for lb rules for ipv6. Format as [frontend_port, protocol, backend_port]"
  # #   type        = map(any)
  # #   default     = {}
  # # }

  # # variable "lb_remote_port_ipv6" {
  # #   description = "Protocols to be used for remote vm access. [protocol, backend_port].  Frontend port will be automatically generated starting at 50000 and in the output."
  # #   type        = map(any)
  # #   default     = {}
  # # }

  # #--------VM backup variables--------------------------
  # variable "enable_vm_backup" {
  #   description = "Enable VM backup or not"
  #   type        = bool
  #   default     = false
  # }

  # variable "vm_recovery_vault_sku" {
  #   description = "Sku of the recovery_services_vault to be created"
  #   default     = "Standard"
  # }

  # variable "backup_recovery_vault_name_suffix" {
  #   description = "Backup recovery vault name"
  #   type        = string
  #   default     = ""
  # }

  # variable "timezone" {
  #   description = "(Optional) Specifies the timezone. Defaults to UTC"
  #   type        = string
  #   default     = "UTC"
  # }

  # variable "vm_backup" {
  #   description = "Configures the Policy backup frequency, times & days"
  #   type        = any
  #   default = {
  #     frequency = "Daily" #(Required) Sets the backup frequency. Must be either Daily or Weekly.
  #     time      = "23:00" #(Required) The time of day to perform the backup in 24hour format.
  #     #weekdays = ["Sunday"]    #(Optional) The days of the week to perform backups on.
  #   }
  # }

  # variable "vm_retention_daily_count" {
  #   description = "The number of daily backups to keep. Must be between 7 and 9999. Required when backup frequency is Daily."
  #   type        = number
  #   default     = 7
  # }

  # variable "vm_retention_weekly" {
  #   description = "(Optional) Configures the policy weekly retention. Required when backup frequency is Weekly"
  #   type        = any
  #   default = {
  #     count    = 42                                            #The number of weekly backups to keep. Must be between 1 and 9999
  #     weekdays = ["Sunday", "Wednesday", "Friday", "Saturday"] #The weekday backups to retain. Must be one of Sunday, Monday, Tuesday, Wednesday, Thursday, Friday or Saturday.
  #   }
  # }

  # variable "vm_retention_monthly" {
  #   description = "(Optional) Configures the policy monthly retention. Required when backup frequency is monthly"
  #   type        = any
  #   default = {
  #     count    = 7
  #     weekdays = ["Sunday", "Wednesday"]
  #   weeks = ["First", "Last"] }
  # }

  # variable "vm_retention_yearly" {
  #   description = "(Optional) Configures the policy yearly retention. Required when backup frequency is yearly"
  #   type        = any
  #   default = {
  #     count    = 77
  #     weekdays = ["Sunday"]
  #     weeks    = ["Last"]
  #     months   = ["January"]
  #   }
  # }

  # #------------VM Auto shutdown variables------------
  # variable "enable_vm_autoshutdown" {
  #   description = "Enable autoshutdown for VM"
  #   type        = bool
  #   default     = true
  # }

  # variable "vm_autoshutdown_daily_recurrence_time" {
  #   description = "(Required) The time each day when the schedule takes effect. Must match the format HHmm where HH is 00-23 and mm is 00-59 (e.g. 0930, 2300, etc.)"
  #   type        = string
  #   default     = "1100"
  # }

  # variable "VM_shutdown_timezone" {
  #   description = "(Required) The time zone ID (e.g. Pacific Standard time)."
  #   type        = string
  #   default     = "UTC"
  # }

  # variable "vm_autoshutdown_notification_settings" {
  #   description = "Block supports: enabled, time_in_minutes and webhook_url"
  #   type        = any
  #   default = {
  #     enabled         = true                                     #(Optional) Whether to enable pre-shutdown notifications. Possible values are true and false. Defaults to false.
  #     time_in_minutes = "60"                                     #(Optional) Time in minutes between 15 and 120 before a shutdown event at which a notification will be sent. Defaults to 30.
  #     webhook_url     = "https://sample-webhook-url.example.com" #The webhook URL to which the notification will be sent. Required if enabled is true. Optional otherwise.
  #   }
  # }

  # #------OS diagnostics variables--------
  # variable "configuration_json" {
  #   default = "{\"diagnosticMonitorConfiguration\":{\"metrics\":{\"resourceId\":\"%VirtualMachineResourceId%\",\"metricAggregation\":[{\"scheduledTransferPeriod\":\"PT1H\"},{\"scheduledTransferPeriod\":\"PT1M\"}]},\"performanceCounters\":{\"performanceCounterConfiguration\":[{\"class\":\"Memory\",\"counterSpecifier\":\"PercentAvailableMemory\",\"table\":\"LinuxMemory\"},{\"class\":\"Memory\",\"counterSpecifier\":\"AvailableMemory\",\"table\":\"LinuxMemory\"},{\"class\":\"Memory\",\"counterSpecifier\":\"UsedMemory\",\"table\":\"LinuxMemory\"},{\"class\":\"Memory\",\"counterSpecifier\":\"PercentUsedSwap\",\"table\":\"LinuxMemory\"},{\"class\":\"Processor\",\"counterSpecifier\":\"PercentProcessorTime\",\"table\":\"LinuxCpu\"},{\"class\":\"Processor\",\"counterSpecifier\":\"PercentIOWaitTime\",\"table\":\"LinuxCpu\"},{\"class\":\"Processor\",\"counterSpecifier\":\"PercentIdleTime\",\"table\":\"LinuxCpu\"},{\"class\":\"PhysicalDisk\",\"counterSpecifier\":\"AverageWriteTime\",\"table\":\"LinuxDisk\"},{\"class\":\"PhysicalDisk\",\"counterSpecifier\":\"AverageReadTime\",\"table\":\"LinuxDisk\"},{\"class\":\"PhysicalDisk\",\"counterSpecifier\":\"ReadBytesPerSecond\",\"table\":\"LinuxDisk\"},{\"class\":\"PhysicalDisk\",\"counterSpecifier\":\"WriteBytesPerSecond\",\"table\":\"LinuxDisk\"}]}}}"
  # }

  # variable "os_diagnostics_storage_account_type" {
  #   description = "Defines the type of storage account to be created for OS diagnostics. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  #   type        = string
  #   default     = "Standard_LRS"
  # }

  # variable "enable_os_diagnostics" {
  #   description = "Enable OS diagnostics."
  #   type        = bool
  #   default     = false
  # }
#-------------------------------
# Module: Application Gateway
#-------------------------------
  # COMMON
  variable "app_gateway_tags" {
    description = "Application Gateway tags."
    type        = map(string)
    default     = {}
  }

  variable "app_gateway_extra_tags" {
    description = "Extra tags to add" #tags for resources created other than application gateway(like public IP, subnet etc)
    type        = map(string)
    default     = {}
  }

  variable "appgw_location" {
    description = "Region is which network will be created. If set to null, network will be created in the region where resource group is situated."
    type = string
    default = null
  }  

  # PUBLIC IP
  variable "app_gateway_ip_name" {
    description = "Public IP name."
    type        = string
    default     = ""
  }

  variable "app_gateway_ip_tags" {
    description = "Public IP tags."
    type        = map(string)
    default     = {}
  }

  variable "app_gateway_ip_label" {
    description = "Domain name label for public IP."
    type        = string
    default     = ""
  }

  variable "app_gateway_ip_sku" {
    description = "SKU for the public IP. Warning, can only be `Standard` for the moment."
    type        = string
    default     = "Standard"
  }

  variable "app_gateway_ip_allocation_method" {
    description = "Allocation method for the public IP. Warning, can only be `Static` for the moment."
    type        = string
    default     = "Static"
  }

  # Application gateway inputs

  variable "appgw_name" {
    description = "Application Gateway name.(Optional)"
    type        = string
    default     = ""
  }

  variable "appgw_sku_capacity" {
    description = "The Capacity of the SKU to use for this Application Gateway - which must be between 1 and 10, optional if autoscale_configuration is set"
    type        = number
    default     = null
  }

  variable "appgw_sku" {
    description = "The Name of the SKU to use for this Application Gateway. Possible values are Standard_v2 and WAF_v2."
    type        = string
    default     = "WAF_v2"
  }

  variable "appgw_autoscale_configuration" {
    description = "Autoscaling configuration for the application gateway"
    type        = list(map(string))
    default = [{
      min_capacity = "1"
      max_capacity = "4"
    }]
  }

  # variable "appgw_zones" {
  #   description = "A collection of availability zones to spread the Application Gateway over. This option is only supported for v2 SKUs"
  #   type        = list(string)
  #   default     = ["1", "2", "3"]
  # }

  variable "appgw_enable_http2" {
    description = "Enable HTTP2"
    type        = bool
    default     = false
  }

  variable "appgw_frontend_ip_configuration_name" {
    description = "The Name of the Frontend IP Configuration used for this HTTP Listener.(Optional)"
    type        = string
    default     = ""
  }

  variable "appgw_frontend_private_ip_address" {
    description = "The private IP address to be used for the Frontend IP Configuration of this HTTP Listener."
    default     = null
  }

  variable "appgw_frontend_private_ip_address_allocation" {
    description = "The allocation method to be used for frontend private IP address. Can be Static or Dynamic. Only Static IP can be used with v2 tiers."
    default     = "Static"
  }

  variable "appgw_enable_frontend_public_ip" {
    description = "Whether public ip should be configured for the frontend IP."
    type        = bool
    default     = false
  }


  variable "appgw_gateway_ip_configuration_name" {
    description = "The Name of the Application Gateway IP Configuration.(Optional)"
    type        = string
    default     = ""
  }

  variable "appgw_frontend_port_settings" {
    description = "Frontend port settings. Each port setting contains the name and the port for the frontend port."
    type        = list(map(string))
    default = [{
      name = "frontend-https-port"
      port = 443
    }]
  }

  variable "appgw_ssl_policy" {
    description = "Application Gateway SSL configuration. The list of available policies can be found here: https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-ssl-policy-overview#predefined-ssl-policy"
    type        = any
    default     = []
  }

  variable "appgw_trusted_root_certificate_configs" {
    description = "List of trusted root certificates. The needed values for each trusted root certificates are 'name' and 'data'."
    type        = list(map(string))
    default     = []
  }

  variable "ssl_certificates_config_name" {
    description = "Name of the SSL certificate config."
    default     = "test-example-com-sslcert"
  }
  variable "ssl_certificate_path" {
    description = "Path of trusted root certificates. "
    default     = "./certificate.pfx"
  }

  variable "ssl_certificate_password" {
    description = "Password of trusted root certificates. "
    default     = "password"
  }
  variable "appgw_backend_pools" {
    description = "List of maps including backend pool configurations"
    type        = any
    default = [{
      name  = "backendpool"
      fqdns = ["example.com"]
    }]
  }

  variable "appgw_http_listeners" {
    description = "List of maps including http listeners configurations"
    type        = list(map(string))
    default = [{
      name                           = "listener-https"
      frontend_ip_configuration_name = "frontipconfig"
      frontend_port_name             = "frontend-https-port"
      protocol                       = "Https"
      ssl_certificate_name           = "test-example-com-sslcert"
      host_name                      = "example.com"
      require_sni                    = true
    }]
  }

  # variable "appgw_ssl_certificates_configs" {
  #   description = "List of maps including ssl certificates configurations"
  #   type        = list(map(string))
  #   default     = []
  # }

  variable "appgw_routings" {
    description = "List of maps including request routing rules configurations"
    type        = list(map(string))
    default = [{
      name                       = "routing-https"
      rule_type                  = "Basic"
      http_listener_name         = "listener-https"
      backend_address_pool_name  = "backendpool"
      backend_http_settings_name = "backhttpsettings"
    }]
  }

  variable "appgw_probes" {
    description = "List of maps including request probes configurations"
    type        = any
    default     = []
  }

  variable "appgw_backend_http_settings" {
    description = "List of maps including backend http settings configurations"
    type        = any
    default = [{
      name                  = "backhttpsettings"
      cookie_based_affinity = "Disabled"
      path                  = "/"
      port                  = 443
      protocol              = "Https"
      request_timeout       = 300
    }]
  }

  variable "appgw_url_path_map" {
    description = "List of maps including url path map configurations"
    type        = any
    default     = []
  }

  variable "appgw_redirect_configuration" {
    description = "List of maps including redirect configurations"
    type        = list(map(string))
    default     = []
  }

  ### REWRITE RULE SET

  variable "appgw_rewrite_rule_set" {
    description = "List of rewrite rule set including rewrite rules"
    type        = any
    default     = []
  }

  ### WAF

  variable "appgw_enable_waf" {
    description = "Boolean to enable WAF."
    type        = bool
    default     = true
  }

  variable "appgw_file_upload_limit_mb" {
    description = " The File Upload Limit in MB. Accepted values are in the range 1MB to 500MB. Defaults to 100MB."
    type        = number
    default     = 100
  }

  variable "appgw_waf_mode" {
    description = "The Web Application Firewall Mode. Possible values are Detection and Prevention."
    type        = string
    default     = "Detection"
  }

  variable "appgw_max_request_body_size_kb" {
    description = "The Maximum Request Body Size in KB. Accepted values are in the range 1KB to 128KB."
    type        = number
    default     = 128
  }

  variable "appgw_request_body_check" {
    description = "Is Request Body Inspection enabled?"
    type        = bool
    default     = true
  }

  variable "appgw_rule_set_type" {
    description = "The Type of the Rule Set used for this Web Application Firewall."
    type        = string
    default     = "OWASP"
  }

  variable "appgw_rule_set_version" {
    description = "The Version of the Rule Set used for this Web Application Firewall. Possible values are 2.2.9, 3.0, and 3.1."
    type        = number
    default     = 3.1
  }

  variable "appgw_disabled_rule_group_settings" {
    description = "The rule group where specific rules should be disabled. Accepted values can be found here: https://www.terraform.io/docs/providers/azurerm/r/application_gateway.html#rule_group_name"
    type = list(object({
      rule_group_name = string
      rules           = list(string)
    }))
    default = []
  }

  variable "appgw_waf_exclusion_settings" {
    description = "WAF exclusion rules to exclude header, cookie or GET argument. More informations on: https://www.terraform.io/docs/providers/azurerm/r/application_gateway.html#match_variable"
    type        = list(map(string))
    default     = []
  }

  ### LOGGING

  # variable "appgw_enable_logging" {
  #   description = "Boolean flag to specify whether logging is enabled"
  #   type        = bool
  #   default     = true
  # }

  # variable "appgw_diag_settings_name" {
  #   description = "Custom name for the diagnostic settings of Application Gateway.(Optional)"
  #   type        = string
  #   default     = ""
  # }

  # variable "appgw_logs_storage_retention" {
  #   description = "Retention in days for logs on Storage Account"
  #   type        = number
  #   default     = 30
  # }

  # variable "appgw_logs_storage_account_id" {
  #   description = "Storage Account id for logs"
  #   type        = string
  #   default     = null
  # }

  # variable "appgw_logs_log_analytics_workspace_id" {
  #   description = "Log Analytics Workspace id for logs"
  #   type        = string
  #   default     = null
  # }

  # variable "appgw_log_storage_account_type" {
  #   description = "Defines the type of storage account to be created for appgw logs. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  #   type        = string
  #   default     = "Standard_LRS"
  # }

  # variable "appgw_log_analytics_workspace_sku" {
  #   description = "The SKU (pricing level) of the Log Analytics workspace. For new subscriptions the SKU should be set to PerGB2018"
  #   type        = string
  #   default     = "PerGB2018"
  # }

  #Either a `eventhub_authorization_rule_id`, `log_analytics_workspace_id` or `storage_account_id` must be set if logging is enabled
  # variable "appgw_eventhub_authorization_rule_id" {
  #   description = "Eventhub Authorization rule id for log transmission"
  #   type        = string
  #   default     = null
  # }

  ### NETWORKING

  variable "appgw_subnet_resource_group_name" {
    description = "Resource group name of the subnet.(Optional)"
    type        = string
    default     = ""
  }

  variable "appgw_create_subnet" {
    description = "Boolean to create subnet with this module."
    type        = bool
    default     = true
  }

  variable "apgw_vnet_subnet_index" {
    description = "Index of custom subnet created for attaching the Application Gateway. Used only when the variable `create_subnet = false`."
    type        = number
    default     = 1
  }

  variable "appgw_route_table_ids" {
    description = "The Route Table Ids map to associate with the subnets. "
    type        = map(string)
    default     = {}
  }

  variable "appgw_custom_subnet_name" {
    description = "Custom name for the subnet.(Optional)"
    type        = string
    default     = ""
  }

  variable "appgw_subnet_cidr" {
    description = "Subnet CIDR to create."
    type        = string
    default     = ""
  }

  variable "appgw_create_nsg" {
    description = "Boolean to create the network security group."
    type        = bool
    default     = true
  }

  variable "appgw_create_nsg_https_rule" {
    description = "Boolean to create the network security group rule opening https to everyone."
    type        = bool
    default     = true
  }

  variable "appgw_create_nsg_healthprobe_rule" {
    description = "Boolean to create the network security group rule for the health probes."
    type        = bool
    default     = true
  }

  variable "appgw_custom_nsg_name" {
    description = "Custom name for the network security group.(Optional)"
    type        = string
    default     = null
  }

  variable "appgw_custom_nsr_https_name" {
    description = "Custom name for the network security rule for HTTPS protocol.(Optional)"
    type        = string
    default     = null
  }

  variable "appgw_custom_nsr_healthcheck_name" {
    description = "Custom name for the network security rule for internal health check of Application Gateway.(Optional)"
    type        = string
    default     = null
  }

  variable "appgw_create_network_security_rules" {
    description = "Boolean to define is default network security rules should be create or not. Default rules are for port 443 and for the range of ports 65200-65535 for Application Gateway healthchecks."
    type        = bool
    default     = true
  }

  variable "appgw_nsr_https_source_address_prefix" {
    description = "Source address prefix to allow to access on port 443 defined in dedicated network security rule."
    type        = string
    default     = "*"
  }

  ### IDENTITY

  variable "appgw_user_assigned_identity_id" {
    description = "User assigned identity id assigned to this resource"
    type        = string
    default     = null
  }

#--------------------------------
# Module: AKS
#--------------------------------

  variable "aks_location" {
    description = "Region is which aks will be created. If set to null, aks will be created in the region where resource group is situated."
    type = string
    default = null
  }

  variable "aks_admin_username" {
    description = "The username of the local administrator to be created on the Kubernetes cluster"
    type        = string
    default     = "azureuser"
  }

  variable "aks_agents_size" {
    description = "The default virtual machine size for the Kubernetes agents"
    type        = string
    default     = "Standard_D2s_v3"
  }

  # variable "aks_log_analytics_workspace_sku" {
  #   description = "The SKU (pricing level) of the Log Analytics workspace. For new subscriptions the SKU should be set to PerGB2018"
  #   type        = string
  #   default     = "PerGB2018"
  # }

  # variable "aks_log_retention_in_days" {
  #   description = "The retention period for the logs in days"
  #   type        = number
  #   default     = 30
  # }

  # variable "aks_agents_count" {
  #   description = "The number of Agents that should exist in the Agent Pool"
  #   type        = number
  #   default     = 2
  # }

  variable "aks_ssh_key" {
    description = "Path to the public key to be used for ssh access to the VM.  Only used with non-Windows vms and can be left as-is even if using Windows vms. If specifying a path to a certification on a Windows machine to provision a linux vm use the / in the path versus backslash. e.g. c:/home/id_rsa.pub."
    type        = string
    default     = ""
  }

  variable "aks_use_existing_ssh_key" {
    description = "Generates a secure private key and encodes it as PEM."
    default     = false
  }

  variable "aks_windows_admin_password" {
    description = "The admin password to be used on the Windows VMs."
    type        = string
    default     = "Nci-automation@123"
  }

  variable "aks_tags" {
    type        = map(string)
    description = "Any tags that should be present on the Virtual Network resources"
    default     = {}
  }

  # variable "aks_enable_log_analytics_workspace" {
  #   type        = bool
  #   description = "Enable the creation of azurerm_log_analytics_workspace and azurerm_log_analytics_solution or not"
  #   default     = true
  # }

  variable "aks_subnet_index" {
    description = "(Optional) The index of a Subnet where the Kubernetes Node Pool should exist."
    type        = number
    default     = 2
  }

  # variable "aks_os_disk_size_gb" {
  #   description = "Disk size of nodes in GBs."
  #   type        = number
  #   default     = 50
  # }

  variable "aks_sku_tier" {
    description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid"
    type        = string
    default     = "Free"
  }

  variable "aks_enable_role_based_access_control" {
    description = "Enable Role Based Access Control."
    type        = bool
    default     = true
  }

  variable "aks_rbac_aad_managed" {
    description = "Is the Azure Active Directory integration Managed, meaning that Azure will create/manage the Service Principal used for integration."
    type        = bool
    default     = false
  }

  variable "aks_rbac_aad_admin_group_object_ids" {
    description = "Object ID of groups with admin access."
    type        = list(string)
    default     = null
  }

  variable "aks_rbac_aad_client_app_id" {
    description = "The Client ID of an Azure Active Directory Application."
    type        = string
    default     = null
  }

  variable "aks_rbac_aad_server_app_id" {
    description = "The Server ID of an Azure Active Directory Application. Same as APP_ID"
    type        = string
    default     = null
  }

  variable "aks_rbac_aad_server_app_secret" {
    description = "The Server Secret of an Azure Active Directory Application. Same as APP_KEY or client_secret"
    type        = string
    default     = null
  }

  variable "kubernetes_version" {
    description = "Kubernetes version"
    type        = string
    default     = null#"1.17.13"
  }

  variable "default_node_pool" {
    description = "The object to configure the default node pool with number of worker nodes, worker node VM size and Availability Zones."
    type = object({
      name                           = string
      node_count                     = number
      vm_size                        = string
      type                           = string
      zones                          = list(string)
      max_pods                       = number
      os_disk_size_gb                = number
      labels                         = map(string)
      taints                         = list(string)
      cluster_auto_scaling           = bool
      cluster_auto_scaling_min_count = number
      cluster_auto_scaling_max_count = number
      enable_node_public_ip          = bool
    })
    default = {
      name                           = "nodepool"
      node_count                     = 2
      vm_size                        = "Standard_B2s"
      type                           = "VirtualMachineScaleSets" # or AvailabilitySets
      zones                          = null
      max_pods                       = 250
      os_disk_size_gb                = 50
      labels                         = null
      taints                         = null
      cluster_auto_scaling           = true
      cluster_auto_scaling_min_count = 1
      cluster_auto_scaling_max_count = 3
      enable_node_public_ip          = true
    }
  }

  variable "additional_node_pools" {
    description = "The map object to configure one or several additional node pools with number of worker nodes, worker node VM size and Availability Zones."
    type = map(object({
      node_count                     = number
      vm_size                        = string
      zones                          = list(string)
      max_pods                       = number
      os_disk_size_gb                = number
      labels                         = map(string)
      taints                         = list(string)
      node_os                        = string
      cluster_auto_scaling           = bool
      cluster_auto_scaling_min_count = number
      cluster_auto_scaling_max_count = number
      enable_node_public_ip          = bool
    }))
    default = {
      "pool2" = {
        node_count                     = 2
        vm_size                        = "Standard_B2s"
        zones                          = null #["1", "2", "3"]
        max_pods                       = 250
        os_disk_size_gb                = 50
        labels                         = null
        taints                         = null
        node_os                        = "Linux"         # Windows agent pools can only be added to AKS clusters using Azure-CNI.
        cluster_auto_scaling           = true
        cluster_auto_scaling_min_count = 1
        cluster_auto_scaling_max_count = 3
        enable_node_public_ip          = true
      }
    }
  }

  # variable "enable_windows_profile" {
  #   description = "True if windows profile has to be enabled for nodes."
  #   type = bool
  #   default = false
  # }

  variable "addons" {
    description = "Defines which addons will be activated."
    type = object({
      oms_agent                = bool
    })
    default = {
      oms_agent                = true
      # virtual_nodes = true
    }
  }

  # variable "aci_subnet_name" {
  #   description = "Name of the subnet to be used for virtual nodes"
  #   default = ""
  # }

  variable "api_auth_ips" {
    description = "Whitelist of IP addresses that are allowed to access the AKS Master Control Plane API. Private cluster cannot be enabled with AuthorizedIPRanges."
    type        = list(string)
    default = null
  }

  variable "private_cluster" {
    description = "Deploy an AKS cluster without a public accessible API endpoint."
    type        = bool
    default = true
  }

  variable "system_assigned_managed_identity" {
    description = " Use system assigned managed identity instead of service principal"
    type = bool
    default = false
  }

  variable "network_profile" {
    description = "Network profile to be used. If network_profile is not defined, kubenet profile will be used by default."
    type = object({
      load_balancer_sku  = string
      outbound_type      = string
      network_plugin     = string    
      network_policy     = string
      dns_service_ip     = string
      docker_bridge_cidr = string
      service_cidr       = string
    })
    default =  {   
      load_balancer_sku  = "standard"
      outbound_type      = "loadBalancer"
      network_plugin     = "kubenet"    # (Required) Currently supported values are azure and kubenet.
      network_policy     = "none"   #  (Optional) This field can only be set when network_plugin is set to azure. Currently supported values are calico and azure. 
      dns_service_ip     = null # required when network_plugin is set to azure else Optional. It is IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)
      docker_bridge_cidr = null # Required when network_plugin is set to azure else Optional. IP address (in CIDR notation) used as the Docker bridge IP address on nodes. 
      service_cidr       = null # Required when network_plugin is set to azure else Optional. It is the Network Range used by the Kubernetes service. 
    }
  }

  variable "node_resource_group" {
    description = "Name of autogenerated Resource Group which will contain the resources for this Managed Kubernetes Cluster."
    type = string
    default = null
  }

#-------------------------
# Module: SQL
#-------------------------

  variable "sql_location" {
    description = "Azure location for SQL Server."
    type        = string
    default = ""
  }

  variable "sql_name_suffix" {
    description = "Optional suffix for the generated name"
    type        = string
    default     = ""
  }

  variable "sql_server_version" {
    description = "Version of the SQL Server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server). See https://www.terraform.io/docs/providers/azurerm/r/sql_server.html#version"
    type        = string
    default     = "12.0"
  }

  variable "sql_allowed_cidr_list" {
    description = "Allowed IP addresses to access the server in CIDR format. Default to all Azure services"
    type        = list(string)
    default     = ["0.0.0.0/32"]
  }

  variable "sql_extra_tags" {
    description = "Extra tags to add"
    type        = map(string)
    default     = {}
  }

  variable "sql_server_extra_tags" {
    description = "Extra tags to add on SQL Server"
    type        = map(string)
    default     = {}
  }

  # variable "sql_elastic_pool_extra_tags" {
  #   description = "Extra tags to add on the SQL Elastic Pool"
  #   type        = map(string)
  #   default     = {}
  # }

  variable "sql_databases_extra_tags" {
    description = "Extra tags to add on the SQL databases"
    type        = map(string)
    default     = {}
  }

  variable "sql_server_custom_name" {
    description = "Name of the SQL Server, generated if not set."
    type        = string
    default     = ""
  }

  # variable "sql_elastic_pool_custom_name" {
  #   description = "Name of the SQL Elastic Pool, generated if not set."
  #   type        = string
  #   default     = ""
  # }

  variable "sql_administrator_login" {
    description = "Administrator login for SQL Server"
    type        = string
    default = "necuser"
  }

  variable "sql_administrator_password" {
    description = "Administrator password for SQL Server"
    type        = string
    default = "Nec@1234"
  }

  # variable "sql_elastic_pool_max_size" {
  #   description = "Maximum size of the Elastic Pool in gigabytes"
  #   type        = string
  #   default = "4.8828125"
  # }

  # variable "sql_sku" {
  #   description = <<DESC
  #     SKU for the Elastic Pool with tier and eDTUs capacity. Premium tier with zone redundancy is mandatory for high availability.
  #     Possible values for tier are "GeneralPurpose", "BusinessCritical", "Basic", "Standard", or "Premium". Example {tier="Standard", capacity="50"}.
  #     See https://docs.microsoft.com/en-us/azure/sql-database/sql-database-dtu-resource-limits-elastic-pools"
  # DESC

  #   type = map(string)
  #   default = {
  #   tier   = "Basic"
  #   family = "Gen5"  # (Optional) The family of hardware Gen4 or Gen5
  #   capacity = "50"  
  # }
  # }

  # variable "sql_zone_redundant" {
  #   description = "Whether or not the Elastic Pool is zone redundant, SKU tier must be Premium to use it. This is mandatory for high availability."
  #   type        = bool
  #   default     = false
  # }

  # variable "sql_database_min_dtu_capacity" {
  #   description = "The minimum capacity all databases are guaranteed in the Elastic Pool. Defaults to 0."
  #   type        = string
  #   default     = "0"
  # }

  # variable "sql_database_max_dtu_capacity" {
  #   description = "The maximum capacity any one database can consume in the Elastic Pool. Default to the max Elastic Pool capacity. The DTU max per database must be less than (5) for service tier 'Basic'"
  #   type        = string
  #   default     = ""
  # }

  variable "sql_nb_database" {
    description = "Number of the databases to create for this server"
    type        = number
    default = 1
  }

  variable "sql_databases_collation" {
    description = "SQL Collation for the databases"
    type        = string
    default     = "SQL_LATIN1_GENERAL_CP1_CI_AS"
  }

  # variable "sql_enable_logging" {
  #   description = "Boolean flag to specify whether logging is enabled"
  #   type        = bool
  #   default     = true
  # }

  # variable "sql_log_storage_account_type" {
  #   description = "Defines the type of storage account to be created for sql logs. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  #   type        = string
  #   default     = "Standard_LRS"
  # }

  # variable "sql_logs_storage_retention" {
  #   description = "Retention in days for logs on Storage Account"
  #   type        = number
  #   default     = 30
  # }

  # variable "sql_log_analytics_workspace_sku" {
  #   description = "The SKU (pricing level) of the Log Analytics workspace. For new subscriptions the SKU should be set to PerGB2018"
  #   type        = string
  #   default     = "PerGB2018"
  # }

  variable "sql_enable_advanced_data_security" {
    description = "Boolean flag to enable Advanced Data Security. The cost of ADS is aligned with Azure Security Center standard tier pricing. See https://docs.microsoft.com/en-us/azure/sql-database/sql-database-advanced-data-security"
    type        = bool
    default     = false
  }

  variable "sql_enable_advanced_data_security_admin_emails" {
    description = "Boolean flag to define if account administrators should be emailed with Advanced Data Security alerts."
    type        = bool
    default     = false
  }

  variable "sql_advanced_data_security_additional_emails" {
    description = "List of additional email addresses for Advanced Data Security alerts."
    type        = list(string)
    # https://github.com/terraform-providers/terraform-provider-azurerm/issues/1974
    default = ["john.doe@azure.com"]
  }

  variable "sql_create_databases_users" {
    description = "True to create a user named <db>_user per database with generated password and role db_owner."
    type        = bool
    default     = true
  }

  variable "sql_daily_backup_retention" {
    description = "Retention in days for the databases backup. Value can be 7, 14, 21, 28 or 35."
    type        = number
    default     = 35
  }

  variable "sql_weekly_backup_retention" {
    description = "Retention in weeks for the weekly databases backup."
    type        = number
    default     = 0
  }

  variable "sql_monthly_backup_retention" {
    description = "Retention in months for the monthly databases backup."
    type        = number
    default     = 3
  }

  variable "sql_yearly_backup_retention" {
    description = "Retention in years for the yearly backup."
    type        = number
    default     = 0
  }

  variable "sql_yearly_backup_time" {
    description = "Week number taken in account for the yearly backup retention."
    type        = number
    default     = 52
  }

  variable "sql_requested_service_objective_name" {
    description = "(Optional) The service objective name for the database. Valid values depend on edition and location and may include S0, S1, S2, S3, P1, P2, P4, P6, P11 and ElasticPool. You can list the available names with the cli: shell az sql db list-editions -l westus -o table."
    type = string
    default = "GP_Gen5_2"
  }

  # variable "sql_db_max_size_bytes" {
  #   description = "(Optional) The maximum size that the database can grow to. Applies only if create_mode is Default."
  #   type = string
  #   default = "5368709120"
  # }

  variable "sql_db_read_scale" {
    description = "(Optional) Read-only connections will be redirected to a high-available replica."
    type = bool
    default = false
  }

#-----------------------------------------
#     Ansible
#-----------------------------------------
  variable "arguments" {
    default = []
    type    = list
    description = "Arguments"
  }

  variable "envs" {
    default = []
    type    = list
    description = "Environment variables"
  }

  variable "playbook" {
    default = ""
    description = "Playbook to run"
  }

  variable "dry_run" {
    default = true
    description = "Do dry run"
  }

  variable "deployment_file" {
    default = ""
    description = "Deployment file to run"
  }