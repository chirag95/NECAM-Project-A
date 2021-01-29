module "os" {
  source       = "./os"
  vm_os_simple = var.vm_os_simple
}

locals {
  sg_rules    = var.nsg_rules
  name_prefix = "${var.stack}-${var.environment}"
  vm_ids = concat(azurerm_virtual_machine.vm-windows.*.id, azurerm_virtual_machine.vm-linux.*.id)
  linux_vm_ids = azurerm_virtual_machine.vm-linux.*.id
  linux_vm_names = azurerm_virtual_machine.vm-linux.*.name
  windows_vm_ids = azurerm_virtual_machine.vm-windows.*.id
  windows_vm_names = azurerm_virtual_machine.vm-windows.*.name
  default_tags = {
    env   = var.environment
    stack = var.stack
  }
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "random_id" "vm-sa" {
  keepers = {
    vm_hostname = var.vm_hostname
  }

  byte_length = 6
}

resource "azurerm_storage_account" "vm-sa" {
  count                    = var.boot_diagnostics && var.nb_instances > 0 ? 1 : 0
  name                     = "bootdiag${lower(random_id.vm-sa.hex)}"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = coalesce(var.location, data.azurerm_resource_group.rg.location)
  account_tier             = element(split("_", var.boot_diagnostics_sa_type), 0)
  account_replication_type = element(split("_", var.boot_diagnostics_sa_type), 1)
  tags                     = merge(local.default_tags, var.tags)
}

# Create an SSH key
module "private_key" {
  count     = var.enable_ssh_key == true && var.generate_admin_ssh_key == true && ! var.is_windows_image && var.nb_instances > 0 ? 1 : 0
  source    = "../terraform-azure-ssh-key"
  algorithm = "RSA"
  rsa_bits  = 4096
}

#Linux instance with managed data disks
resource "azurerm_virtual_machine" "vm-linux" {
  count                            = ! contains(list(var.vm_os_simple, var.vm_os_offer), "WindowsServer") && ! var.is_windows_image ? var.nb_instances : 0
  name                             = "${var.stack}-${var.environment}-${var.vm_hostname}-${count.index}"
  resource_group_name              = data.azurerm_resource_group.rg.name
  location                         = coalesce(var.location, data.azurerm_resource_group.rg.location)
  availability_set_id              = var.create_availability_set == true ? module.availability_set[0].availability_set_id : null
  vm_size                          = var.vm_size
  network_interface_ids            = [element(azurerm_network_interface.vm_staticnic.*.id, count.index)]
  delete_os_disk_on_termination    = var.delete_os_disk_on_termination
  delete_data_disks_on_termination = var.delete_data_disk_on_termination

  dynamic identity {
    for_each = length(var.identity_ids) == 0 && var.identity_type == "SystemAssigned" ? [var.identity_type] : []
    content {
      type = var.identity_type
    }
  }

  dynamic identity {
    for_each = length(var.identity_ids) > 0 || var.identity_type == "UserAssigned" ? [var.identity_type] : []
    content {
      type         = var.identity_type
      identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : []
    }
  }

  storage_image_reference {
    id        = var.vm_os_id
    publisher = var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""
    offer     = var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""
    sku       = var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""
    version   = var.vm_os_id == "" ? var.vm_os_version : ""
  }

  storage_os_disk {
    name              = "${var.stack}-${var.environment}-osdisk-${var.vm_hostname}-${count.index}"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = var.storage_account_type
  }

  dynamic "storage_data_disk" {
    for_each = var.storage_data_disk
    content {
      name              = "${var.stack}-${var.environment}-${var.vm_hostname}-vmLinux-${count.index}-datadisk-${storage_data_disk.key}"
      create_option     = lookup(storage_data_disk.value, "create_option", "Empty")
      lun               = storage_data_disk.key
      disk_size_gb      = lookup(storage_data_disk.value, "disk_size_gb", 5)
      managed_disk_type = lookup(storage_data_disk.value, "managed_disk_type", "Standard_LRS")
    }
  }

  os_profile {
    computer_name  = "${var.vm_hostname}-${count.index}"
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = var.custom_data
  }

  os_profile_linux_config {
    disable_password_authentication = var.enable_ssh_key

    dynamic ssh_keys {
      for_each = var.enable_ssh_key ? [var.ssh_key] : []
      content {
        path     = "/home/${var.admin_username}/.ssh/authorized_keys"
        key_data = var.generate_admin_ssh_key == true && ! var.is_windows_image ? module.private_key[0].admin_ssh_key_public : file(var.ssh_key)
      }
    }
  }

  tags = merge(local.default_tags, var.tags)

  boot_diagnostics {
    enabled     = var.boot_diagnostics
    storage_uri = var.boot_diagnostics ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : ""
  }
}

resource "azurerm_virtual_machine" "vm-windows" {
  count                         = (var.is_windows_image || contains(list(var.vm_os_simple, var.vm_os_offer), "WindowsServer")) ? var.nb_instances : 0
  name                          = "${local.name_prefix}-${var.vm_hostname}-vmWindows-${count.index}"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = coalesce(var.location, data.azurerm_resource_group.rg.location)
  availability_set_id           = var.create_availability_set == true ? module.availability_set[0].availability_set_id : null
  vm_size                       = var.vm_size
  network_interface_ids         = [element(azurerm_network_interface.vm_staticnic.*.id, count.index)]
  delete_os_disk_on_termination = var.delete_os_disk_on_termination
  license_type                  = var.license_type

  dynamic identity {
    for_each = length(var.identity_ids) == 0 && var.identity_type == "SystemAssigned" ? [var.identity_type] : []
    content {
      type = var.identity_type
    }
  }

  dynamic identity {
    for_each = length(var.identity_ids) > 0 || var.identity_type == "UserAssigned" ? [var.identity_type] : []
    content {
      type         = var.identity_type
      identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : []
    }
  }

  storage_image_reference {
    id        = var.vm_os_id
    publisher = var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""
    offer     = var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""
    sku       = var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""
    version   = var.vm_os_id == "" ? var.vm_os_version : ""
  }

  storage_os_disk {
    name              = "${local.name_prefix}-${var.vm_hostname}-osdisk-${count.index}"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = var.storage_account_type
  }

  dynamic "storage_data_disk" {
    for_each = var.storage_data_disk
    content {
      name              = "${local.name_prefix}-${var.vm_hostname}-datadisk-${count.index}-${storage_data_disk.key}"
      create_option     = lookup(storage_data_disk.value, "create_option", "Empty")
      lun               = storage_data_disk.key
      disk_size_gb      = lookup(storage_data_disk.value, "disk_size_gb", 5)
      managed_disk_type = lookup(storage_data_disk.value, "managed_disk_type", "Standard_LRS")
    }
  }

  os_profile {
    computer_name  = "${substr("${var.stack}-${var.environment}-${var.vm_hostname}-",0,13)}${count.index}" 
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  tags = merge(local.default_tags, var.tags)

  os_profile_windows_config {
    provision_vm_agent = true
  }

  boot_diagnostics {
    enabled     = var.boot_diagnostics
    storage_uri = var.boot_diagnostics ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : ""
  }
}

module "availability_set" {
  count                          = var.create_availability_set && var.nb_instances > 0 ? 1 : 0
  source                         = "../terraform-azure-availability-set"
  name                           = "${local.name_prefix}-${var.vm_hostname}-avset"
  resource_group_name            = data.azurerm_resource_group.rg.name
  location = coalesce(var.location, data.azurerm_resource_group.rg.location)
  platform_fault_domain_count    = var.availability_set_config.platform_fault_domain_count
  platform_update_domain_count   = var.availability_set_config.platform_update_domain_count
  managed                        = var.availability_set_config.managed
  tags                           = merge(local.default_tags,var.availability_set_config.tags)
}

resource "azurerm_public_ip" "vm" {
  count               = var.nb_instances > 0 ? var.nb_public_ip : 0
  name                = "${local.name_prefix}-vm-${var.vm_hostname}-pip-${count.index}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = coalesce(var.location, data.azurerm_resource_group.rg.location)
  sku                 = var.public_ip_sku
  allocation_method   = var.public_ip_allocation_method
  domain_name_label   = element(var.public_ip_dns, count.index)
  tags                = merge(local.default_tags, var.tags)
}

resource "azurerm_network_security_group" "vm" {
  count               = var.nb_instances > 0 ? 1 : 0
  name                = "${local.name_prefix}-${var.vm_hostname}-nsg"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = coalesce(var.location, data.azurerm_resource_group.rg.location)

  tags = merge(local.default_tags, var.tags)
}

resource "azurerm_network_security_rule" "nsg-rules" {
  count                       = var.nb_instances > 0 ? length(keys(local.sg_rules)) : 0
  name                        = "allow-${element(keys(local.sg_rules), count.index)}-in"
  direction                   = lookup(local.sg_rules[element(keys(local.sg_rules), count.index)], "direction")
  access                      = lookup(local.sg_rules[element(keys(local.sg_rules), count.index)], "access", "Allow")
  priority                    = lookup(local.sg_rules[element(keys(local.sg_rules), count.index)], "priority")
  protocol                    = lookup(local.sg_rules[element(keys(local.sg_rules), count.index)], "protocol", "*")
  source_port_range           = "*"
  destination_port_range      = lookup(local.sg_rules[element(keys(local.sg_rules), count.index)], "destination_port", coalesce(module.os.calculated_remote_port, "*"))
  source_address_prefix       = lookup(local.sg_rules[element(keys(local.sg_rules), count.index)], "source_address", "*")
  destination_address_prefix  = lookup(local.sg_rules[element(keys(local.sg_rules), count.index)], "destination_address", "*")
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.vm[0].name
}

resource "azurerm_network_interface" "vm_staticnic" {
  count = var.nb_instances
  name  = "${local.name_prefix}-${var.vm_hostname}-staticnic-${count.index}"
  location                      = coalesce(var.location, data.azurerm_resource_group.rg.location)
  resource_group_name           = data.azurerm_resource_group.rg.name
  enable_accelerated_networking = var.enable_accelerated_networking
  ip_configuration {
    name                          = "${local.name_prefix}-client_host_nic-${count.index}"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = cidrhost(var.private_ips_cidrhost_prefix[0], var.last_hostnum - count.index)
    public_ip_address_id          = length(azurerm_public_ip.vm.*.id) > 0 ? element(concat(azurerm_public_ip.vm.*.id, list("")), count.index) : ""
  }
  tags = merge(local.default_tags, var.tags)
}

resource "azurerm_network_interface_security_group_association" "test" {
  count                     = var.nb_instances
  network_interface_id      = azurerm_network_interface.vm_staticnic[count.index].id
  network_security_group_id = azurerm_network_security_group.vm[0].id
}

module "loadbalancer" {
  count                                  = var.enable_load_balancer == true && var.nb_instances > 1 ? 1 : 0
  source                                 = "../terraform-azure-load-balancer"
  environment                            = var.environment
  stack                                  = var.stack
  resource_group_name                    = data.azurerm_resource_group.rg.name
  location = coalesce(var.location, data.azurerm_resource_group.rg.location)  
  prefix                                 = "${var.vm_hostname}-${var.lb_prefix}"
  lb_sku                                 = var.lb_sku
  remote_port                            = var.lb_remote_port
  lb_port                                = var.lb_port
  lb_probe_unhealthy_threshold           = var.lb_probe_unhealthy_threshold
  lb_probe_interval                      = var.lb_probe_interval
  allocation_method                      = var.lb_allocation_method
  tags                                   = merge(local.default_tags,var.lb_tags)
  type                                   = var.lb_type
  frontend_subnet_id                     = var.vnet_subnet_id
  frontend_private_ip_address            = var.lb_frontend_private_ip_address
  frontend_private_ip_address_allocation = var.lb_frontend_private_ip_address_allocation
  public_ip_sku                          = var.lb_public_ip_sku
  lb_probe                               = var.lb_probe
  ipv4_tags                              = merge(local.default_tags,var.lb_ipv4_tags)
  enable_floating_ip                     = var.enable_floating_ip
}

resource "azurerm_network_interface_backend_address_pool_association" "network_interface_backend_address_pool_association" {
  count                   = var.enable_load_balancer == true && var.nb_instances > 1 ? var.nb_instances : 0
  network_interface_id    = element(azurerm_network_interface.vm_staticnic.*.id, count.index) #fixes interpolation issues
  ip_configuration_name   = "${local.name_prefix}-client_host_nic-${count.index}"
  backend_address_pool_id = module.loadbalancer[0].azurerm_lb_backend_address_pool_id
  depends_on              = [module.loadbalancer, azurerm_network_interface.vm_staticnic]
}

module "vm-backup" {
  count  = var.enable_vm_backup && var.nb_instances > 0 ? 1 : 0
  source = "../terraform-azure-vmbackup"

  resource_group_name        = data.azurerm_resource_group.rg.name
  location = coalesce(var.location, data.azurerm_resource_group.rg.location)
  environment                = var.environment
  stack                      = var.stack
  recovery_vault_sku         = var.recovery_vault_sku
  recovery_vault_name_suffix = var.backup_recovery_vault_name_suffix
  timezone                   = var.timezone
  backup                     = var.vm_backup
  retention_daily_count      = var.retention_daily_count
  retention_weekly           = var.retention_weekly
  retention_monthly          = var.retention_monthly
  retention_yearly           = var.retention_yearly
  vm_count                   = var.nb_instances
  vm_ids                     = local.vm_ids
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "example" {
  count = var.enable_autoshutdown == true ? var.nb_instances : 0
  virtual_machine_id    = local.vm_ids[count.index]
  location              = coalesce(var.location, data.azurerm_resource_group.rg.location)
  enabled               = true
  daily_recurrence_time = var.daily_recurrence_time
  timezone              = var.VM_shutdown_timezone
  notification_settings {
    enabled = lookup(var.notification_settings,"enabled", false)
    time_in_minutes = lookup(var.notification_settings,"time_in_minutes", null)
    webhook_url = lookup(var.notification_settings, "webhook_url", null)
  }
}

module "os_diag_storage_account" {
  count                               = var.enable_os_diagnostics == true && var.nb_instances > 0 ? 1 : 0
  source                              = "../terraform-azure-storage-account"
  resource_group_name                 = data.azurerm_resource_group.rg.name
  location                            = coalesce(var.location, data.azurerm_resource_group.rg.location)
  diagnostics_storage_account_type = var.os_diagnostics_storage_account_type
  tags                                = merge(local.default_tags, var.tags)
  generate_storage_sas_token          = true
  storage_account_name_suffix         = "${random_id.vm-sa.hex}${count.index}"

}
resource "azurerm_virtual_machine_extension" "os_diag" {
  count = var.enable_os_diagnostics == true && ! contains(list(var.vm_os_simple, var.vm_os_offer), "WindowsServer") && ! var.is_windows_image ? var.nb_instances : 0
  name  = "${local.linux_vm_names[count.index]}-diagostics"

  virtual_machine_id         = local.linux_vm_ids[count.index]
  publisher                  = "Microsoft.Azure.Diagnostics"
  type                       = "LinuxDiagnostic"
  type_handler_version       = "3.0"
  auto_upgrade_minor_version = "true"

  settings = <<SETTINGS
    {
      "StorageAccount": "${module.os_diag_storage_account[0].name}",
      "ladCfg": {
          "diagnosticMonitorConfiguration": {
                "eventVolume": "Medium", 
                "metrics": {
                     "metricAggregation": [
                        {
                            "scheduledTransferPeriod": "PT1H"
                        }, 
                        {
                            "scheduledTransferPeriod": "PT1M"
                        }
                    ], 
                    "resourceId": "${local.linux_vm_ids[count.index]}"
                },
                "performanceCounters": ${file("${path.module}/azure_extension_diagnostics_linux_performancecounters.json")},
                "syslogEvents": ${file("${path.module}/azure_extension_diagnostics_linux_syslogevents.json")}
          }, 
          "sampleRateInSeconds": 15
      }
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
        "storageAccountName": "${module.os_diag_storage_account[0].name}",
        "storageAccountSasToken": "${module.os_diag_storage_account[0].storage_account_sas_token}",
        "sinksConfig":  {
              "sink": [
                {
                    "name": "SyslogJsonBlob",
                    "type": "JsonBlob"
                },
                {
                    "name": "LinuxCpuJsonBlob",
                    "type": "JsonBlob"
                }
              ]
        }
    }
  PROTECTED_SETTINGS

  tags = merge(local.default_tags, var.tags)
}

#########################################################
#  VM Extensions - Windows In-Guest Monitoring/Diagnostics
#########################################################
resource "azurerm_virtual_machine_extension" "WindowsInGuestDiagnostics" {
  count = var.enable_os_diagnostics == true && (var.is_windows_image || contains(list(var.vm_os_simple, var.vm_os_offer), "WindowsServer")) ? var.nb_instances : 0
  name                       = "${local.windows_vm_names[count.index]}-diagostics"#var.compute["InGuestDiagnostics"]["name"]
  virtual_machine_id         = local.windows_vm_ids[count.index]
  publisher                  = "Microsoft.Azure.Diagnostics"#var.compute["InGuestDiagnostics"]["publisher"]
  type                       = "IaaSDiagnostics"#var.compute["InGuestDiagnostics"]["type"]
  type_handler_version       = "1.16"#var.compute["InGuestDiagnostics"]["type_handler_version"]
  auto_upgrade_minor_version = "true"#var.compute["InGuestDiagnostics"]["auto_upgrade_minor_version"]

  settings           = <<SETTINGS
    {
      "xmlCfg": "${base64encode(templatefile("${path.module}/wadcfgxml.tmpl", { vmid = local.windows_vm_ids[count.index]}))}",
      "storageAccount": "${module.os_diag_storage_account[0].name}"
    }
SETTINGS
  protected_settings = <<PROTECTEDSETTINGS
    {
      "storageAccountName": "${module.os_diag_storage_account[0].name}",
      "storageAccountKey": "${module.os_diag_storage_account[0].primary_access_key}",
     
      
      "storageAccountEndPoint": "https://core.windows.net"
    }
PROTECTEDSETTINGS
}

# resource "azurerm_virtual_machine_extension" "domjoin" {
#   count = var.nb_instances
#   name = (var.is_windows_image || contains(list(var.vm_os_simple, var.vm_os_offer), "WindowsServer")) ? "${local.windows_vm_names[count.index]}-domjoin" : "${local.linux_vm_names[count.index]}-domjoin"
#   virtual_machine_id         = (var.is_windows_image || contains(list(var.vm_os_simple, var.vm_os_offer), "WindowsServer")) ? local.windows_vm_ids[count.index] : local.linux_vm_ids[count.index]
#   publisher = "Microsoft.Compute"
#   type = "JsonADDomainExtension"
#   type_handler_version = "1.3"
#   settings = <<SETTINGS
#   {
#     "Name": "deise.com",
#     "OUPath": "OU=Servers,DC=deise,DC=com",
#     "User": "deise.com\\pr_admin",
#     "Restart": "true",
#     "Options": "3"
#   }
#   SETTINGS
#   protected_settings = <<PROTECTED_SETTINGS
#   {
#   "Password": "${var.admin_password}"
#   }
#   PROTECTED_SETTINGS
# }  
