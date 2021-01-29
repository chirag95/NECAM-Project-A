# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 1.43.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  skip_provider_registration = true
  features {}
}



#Module to create resource group
module "resgp" {
  source                = "./modules/terraform-azure-resource-group"
  create_resource_group = var.use_existing_resource_group == true ? false : true
  name                  = var.resource_group_name
  location              = var.region
  tags                  = merge(var.common_tags, var.resource_group_tags)
  environment           = var.environment
  stack                 = var.project_name
}

#Module to create virtual network and subnet in the resource group created
module "network" {
  source                = "./modules/terraform-azurerm-network"
  vnet_name_suffix      = var.vnet_name_suffix
  environment           = var.environment
  stack                 = var.project_name
  resource_group_name   = module.resgp.res_group_name
  location              = coalesce(var.network_location, var.common_resource_location, module.resgp.location)
  address_space         = var.address_space
  dns_servers           = var.dns_servers
  subnet_prefixes       = var.subnet_prefixes
  subnet_name_suffix    = var.subnet_name_suffix
  tags                  = merge(var.common_tags, var.vnet_tags)
  ddos_plan_name_suffix = var.ddos_plan_name_suffix
  create_ddos_plan      = var.create_ddos_plan
  ddos_resource_tags    = merge(var.common_tags, var.ddos_resource_tags)
  bastion_config = {
    enable                              = var.enable_bastion
    azure_bastion_service_name_suffix   = var.azure_bastion_service_name_suffix
    azure_bastion_subnet_address_prefix = var.azure_bastion_subnet_address_prefix
    public_ip_allocation_method         = var.public_ip_allocation_method
    public_ip_sku                       = var.public_ip_sku
    domain_name_label                   = var.bastion_domain_name_label
    tags                                = merge(var.common_tags, var.bastion_tags)
  }
  firewall_config = {
    enable                      = var.enable_firewall_for_vnet
    suffix                      = var.firewall_suffix
    public_ip_allocation_method = var.firewall_public_ip_allocation_method
    public_ip_sku               = var.firewall_public_ip_sku
    subnet_address_prefix       = var.azure_firewall_subnet_address_prefix
    tags                        = merge(var.common_tags, var.firewall_tags)
  }
  depends_on = [module.resgp]
}

locals {
  nb_instances_list = tolist(var.vm_config.*.nb_instances)
}

module "compute" {
  count = length(var.vm_config)

  source              = "./modules/terraform-azure-compute"
  environment         = var.environment
  stack               = var.project_name
  resource_group_name = module.resgp.res_group_name
  location            = coalesce(lookup(var.vm_config[count.index], "vm_location", ""), var.common_resource_location, module.resgp.location)

  vm_hostname    = var.vm_config[count.index].vm_hostname_identifier
  vnet_subnet_id = module.network.vnet_subnets[lookup(var.vm_config[count.index], "vnet_subnet_index")]
  public_ip_dns  = lookup(var.vm_config[count.index], "public_ip_dns", [null])
  admin_password = lookup(var.vm_config[count.index], "admin_password", "Nec@123")
  ssh_key        = lookup(var.vm_config[count.index], "ssh_key", "")
  nsg_rules = lookup(var.vm_config[count.index], "nsg_rules", {
    allow_ssh = {
      priority         = 100
      protocol         = "TCP"
      destination_port = "22"
      source_address   = "10.0.0.0/8"
      access           = "Allow"
      direction        = "Inbound"
    }

  })
  admin_username                  = lookup(var.vm_config[count.index], "admin_username", "azureuser")
  custom_data                     = lookup(var.vm_config[count.index], "custom_data", "")
  storage_account_type            = lookup(var.vm_config[count.index], "storage_account_type", "Premium_LRS")
  vm_size                         = lookup(var.vm_config[count.index], "vm_size", "Standard_B2s")
  nb_instances                    = lookup(var.vm_config[count.index], "nb_instances", 1)
  vm_os_simple                    = lookup(var.vm_config[count.index], "vm_os_simple", "CentOS")
  vm_os_id                        = lookup(var.vm_config[count.index], "vm_os_id", "")
  is_windows_image                = lookup(var.vm_config[count.index], "is_windows_image", false)
  vm_os_publisher                 = lookup(var.vm_config[count.index], "vm_os_publisher", "")
  vm_os_offer                     = lookup(var.vm_config[count.index], "vm_os_offer", "")
  vm_os_sku                       = lookup(var.vm_config[count.index], "vm_os_sku", "")
  vm_os_version                   = lookup(var.vm_config[count.index], "vm_os_version", "latest")
  tags                            = merge(var.common_tags, lookup(var.vm_config[count.index], "vm_tags", {}))
  private_ips_cidrhost_prefix     = module.network.vnet_subnet_address_prefixes[lookup(var.vm_config[count.index], "vnet_subnet_index")] #lookup(var.vm_config[count.index], "private_ips", null)
  last_hostnum                    = 4 + sum(slice(local.nb_instances_list, 0, count.index + 1))
  public_ip_allocation_method     = lookup(var.vm_config[count.index], "vm_public_ip_allocation_method", "Static")
  public_ip_sku                   = lookup(var.vm_config[count.index], "vm_public_ip_sku", "Standard")
  nb_public_ip                    = lookup(var.vm_config[count.index], "vm_nb_public_ip", 1)
  delete_os_disk_on_termination   = lookup(var.vm_config[count.index], "delete_os_disk_on_termination", false)
  delete_data_disk_on_termination = lookup(var.vm_config[count.index], "delete_data_disk_on_termination", false)
  storage_data_disk = lookup(var.vm_config[count.index], "storage_data_disk", [{
    create_option     = "Empty"        #(Required) Possible values are Attach, FromImage and Empty.
    disk_size_gb      = 30             #(Required) Specifies the size of the data disk in gigabytes.
    managed_disk_type = "Standard_LRS" #Value must be either Standard_LRS or Premium_LRS.
  }])
  boot_diagnostics              = lookup(var.vm_config[count.index], "boot_diagnostics", false)
  boot_diagnostics_sa_type      = lookup(var.vm_config[count.index], "boot_diagnostics_sa_type", "Standard_LRS")
  enable_accelerated_networking = lookup(var.vm_config[count.index], "enable_accelerated_networking", false)
  enable_ssh_key                = lookup(var.vm_config[count.index], "enable_ssh_key", false)
  generate_admin_ssh_key        = lookup(var.vm_config[count.index], "generate_admin_ssh_key", true)
  source_address_prefixes       = lookup(var.vm_config[count.index], "source_address_prefixes", ["0.0.0.0/0"])
  license_type                  = lookup(var.vm_config[count.index], "license_type", null)
  identity_type                 = lookup(var.vm_config[count.index], "identity_type", "")
  identity_ids                  = lookup(var.vm_config[count.index], "identity_ids", [])
  # Availzbility set
  create_availability_set = lookup(var.vm_config[count.index], "create_availability_set", false)
  availability_set_config = {
    platform_fault_domain_count    = lookup(var.vm_config[count.index], "av_set_platform_fault_domain_count", 2)
    platform_update_domain_count   = lookup(var.vm_config[count.index], "av_set_platform_update_domain_count", 2)
    managed                        = lookup(var.vm_config[count.index], "av_set_managed", true)
    tags                           = merge(var.common_tags, lookup(var.vm_config[count.index], "av_set_tags", {}))
    proximity_placement_group_name = lookup(var.vm_config[count.index], "proximity_placement_group_name", "sample-ppg")
  }
  # Load Balancer
  enable_load_balancer         = lookup(var.vm_config[count.index], "enable_load_balancer", true)
  lb_prefix                    = lookup(var.vm_config[count.index], "loadbalancer_prefix", "")
  lb_sku                       = lookup(var.vm_config[count.index], "load_balancer_sku", "Standard")
  lb_type                      = lookup(var.vm_config[count.index], "load_balancer_type", "private")
  lb_remote_port               = lookup(var.vm_config[count.index], "lb_remote_port", {})
  lb_port                      = lookup(var.vm_config[count.index], "lb_port", {})
  lb_probe                     = lookup(var.vm_config[count.index], "lb_probe", {})
  lb_probe_unhealthy_threshold = lookup(var.vm_config[count.index], "lb_probe_unhealthy_threshold", 2)
  lb_probe_interval            = lookup(var.vm_config[count.index], "lb_probe_interval", 5)
  # lb_frontend_name_suffix                            = lookup(var.vm_config[count.index], "lb_frontend_name_suffix
  lb_allocation_method                      = lookup(var.vm_config[count.index], "lb_allocation_method", "Static")
  lb_tags                                   = merge(var.common_tags, lookup(var.vm_config[count.index], "lb_tags", {}))
  lb_frontend_private_ip_address_allocation = lookup(var.vm_config[count.index], "lb_frontend_private_ip_address_allocation", "Dynamic")
  lb_public_ip_sku                          = lookup(var.vm_config[count.index], "lb_public_ip_sku", "Standard")
  lb_frontend_private_ip_address            = lookup(var.vm_config[count.index], "lb_frontend_private_ip_address", "")
  enable_floating_ip                        = lookup(var.vm_config[count.index], "enable_floating_ip", false)
  lb_ipv4_tags                              = merge(var.common_tags, lookup(var.vm_config[count.index], "lb_ipv4_tags", {}))
  # VM backup
  enable_vm_backup                  = lookup(var.vm_config[count.index], "enable_vm_backup", false)
  recovery_vault_sku                = lookup(var.vm_config[count.index], "vm_recovery_vault_sku", "Standard")
  backup_recovery_vault_name_suffix = lookup(var.vm_config[count.index], "backup_recovery_vault_name_suffix", "")
  timezone                          = lookup(var.vm_config[count.index], "timezone", "UTC")
  vm_backup = lookup(var.vm_config[count.index], "vm_backup", {
    frequency = "Daily" #(Required) Sets the backup frequency. Must be either Daily or Weekly.
    time      = "23:00" #(Required) The time of day to perform the backup in 24hour format.
    #weekdays = ["Sunday"]    #(Optional) The days of the week to perform backups on.
  })
  retention_daily_count = lookup(var.vm_config[count.index], "vm_retention_daily_count", 7)
  retention_weekly = lookup(var.vm_config[count.index], "vm_retention_weekly", {
    count    = 42                                            #The number of weekly backups to keep. Must be between 1 and 9999
    weekdays = ["Sunday", "Wednesday", "Friday", "Saturday"] #The weekday backups to retain. Must be one of Sunday, Monday, Tuesday, Wednesday, Thursday, Friday or Saturday.
  })
  retention_monthly = lookup(var.vm_config[count.index], "vm_retention_monthly", {
    count    = 7
    weekdays = ["Sunday", "Wednesday"]
  weeks = ["First", "Last"] })
  retention_yearly = lookup(var.vm_config[count.index], "vm_retention_yearly", {
    count    = 77
    weekdays = ["Sunday"]
    weeks    = ["Last"]
    months   = ["January"]
  })
  # VM autoshutdown
  enable_autoshutdown   = lookup(var.vm_config[count.index], "enable_vm_autoshutdown", true)
  daily_recurrence_time = lookup(var.vm_config[count.index], "vm_autoshutdown_daily_recurrence_time", "1100")
  VM_shutdown_timezone  = lookup(var.vm_config[count.index], "VM_shutdown_timezone", "UTC")
  notification_settings = lookup(var.vm_config[count.index], "vm_autoshutdown_notification_settings", {
    enabled         = true                                     #(Optional) Whether to enable pre-shutdown notifications. Possible values are true and false. Defaults to false.
    time_in_minutes = "60"                                     #(Optional) Time in minutes between 15 and 120 before a shutdown event at which a notification will be sent. Defaults to 30.
    webhook_url     = "https://sample-webhook-url.example.com" #The webhook URL to which the notification will be sent. Required if enabled is true. Optional otherwise.
  })
  # OS diagnostics
  os_diagnostics_storage_account_type = lookup(var.vm_config[count.index], "os_diagnostics_storage_account_type", "Standard_LRS")
  enable_os_diagnostics               = lookup(var.vm_config[count.index], "enable_os_diagnostics", false)
  depends_on                          = [module.resgp, module.network]
}


module "appgw_v2" {
  source = "./modules/terraform-azure-app-gateway"

  # COMMON
  stack               = var.project_name
  environment         = var.environment
  resource_group_name = module.resgp.res_group_name
  location            = coalesce(var.appgw_location, var.common_resource_location, module.resgp.location)
  app_gateway_tags    = merge(var.common_tags, var.app_gateway_tags)
  extra_tags          = merge(var.common_tags, var.app_gateway_extra_tags)

  # PUBLIC IP
  ip_name              = var.app_gateway_ip_name
  ip_tags              = merge(var.common_tags, var.app_gateway_ip_tags)
  ip_label             = var.app_gateway_ip_label
  ip_sku               = var.app_gateway_ip_sku
  ip_allocation_method = var.app_gateway_ip_allocation_method

  # Application gateway inputs
  appgw_name                             = var.appgw_name
  sku_capacity                           = var.appgw_sku_capacity
  sku                                    = var.appgw_sku
  autoscale_configuration                = var.appgw_autoscale_configuration
  enable_http2                           = var.appgw_enable_http2
  frontend_ip_configuration_name         = var.appgw_frontend_ip_configuration_name
  frontend_private_ip_address            = var.appgw_frontend_private_ip_address
  frontend_private_ip_address_allocation = var.appgw_frontend_private_ip_address_allocation
  enable_frontend_public_ip              = var.appgw_enable_frontend_public_ip
  gateway_ip_configuration_name          = var.appgw_gateway_ip_configuration_name
  frontend_port_settings                 = var.appgw_frontend_port_settings
  ssl_policy                             = var.appgw_ssl_policy
  trusted_root_certificate_configs       = var.appgw_trusted_root_certificate_configs
  appgw_backend_pools                    = var.appgw_backend_pools
  appgw_http_listeners                   = var.appgw_http_listeners
  ssl_certificates_configs = [{
    name     = var.ssl_certificates_config_name
    data     = filebase64(var.ssl_certificate_path)
    password = var.ssl_certificate_password
  }]
  appgw_routings               = var.appgw_routings
  appgw_probes                 = var.appgw_probes
  appgw_backend_http_settings  = var.appgw_backend_http_settings
  appgw_url_path_map           = var.appgw_url_path_map
  appgw_redirect_configuration = var.appgw_redirect_configuration
  ### REWRITE RULE SET
  appgw_rewrite_rule_set = var.appgw_rewrite_rule_set
  ### WAF
  enable_waf                   = var.appgw_enable_waf
  file_upload_limit_mb         = var.appgw_file_upload_limit_mb
  waf_mode                     = var.appgw_waf_mode
  max_request_body_size_kb     = var.appgw_max_request_body_size_kb
  request_body_check           = var.appgw_request_body_check
  rule_set_type                = var.appgw_rule_set_type
  rule_set_version             = var.appgw_rule_set_version
  disabled_rule_group_settings = var.appgw_disabled_rule_group_settings
  waf_exclusion_settings       = var.appgw_waf_exclusion_settings
  ### NETWORKING
  virtual_network_name            = module.network.vnet_name
  subnet_resource_group_name      = var.appgw_subnet_resource_group_name
  create_subnet                   = var.appgw_create_subnet
  subnet_id                       = module.network.vnet_subnets[var.apgw_vnet_subnet_index]
  route_table_ids                 = var.appgw_route_table_ids
  custom_subnet_name              = var.appgw_custom_subnet_name
  subnet_cidr                     = var.appgw_subnet_cidr
  create_nsg                      = var.appgw_create_nsg
  create_nsg_https_rule           = var.appgw_create_nsg_https_rule
  create_nsg_healthprobe_rule     = var.appgw_create_nsg_healthprobe_rule
  custom_nsg_name                 = var.appgw_custom_nsg_name
  custom_nsr_https_name           = var.appgw_custom_nsr_https_name
  custom_nsr_healthcheck_name     = var.appgw_custom_nsr_healthcheck_name
  create_network_security_rules   = var.appgw_create_network_security_rules
  nsr_https_source_address_prefix = var.appgw_nsr_https_source_address_prefix
  ### IDENTITY
  user_assigned_identity_id = var.appgw_user_assigned_identity_id
  depends_on                = [module.resgp, module.network]
}

module "aks" {
  source                           = "./modules/terraform-azure-aks"
  resource_group_name              = module.resgp.res_group_name
  location                         = coalesce(var.aks_location, var.common_resource_location, module.resgp.location)
  stack                            = var.project_name
  environment                      = var.environment
  node_resource_group              = var.node_resource_group
  kubernetes_version               = var.kubernetes_version
  client_id                        = var.client_id
  client_secret                    = var.client_secret
  admin_username                   = var.aks_admin_username
  ssh_key                          = var.aks_ssh_key
  use_existing_ssh_key             = var.aks_use_existing_ssh_key
  admin_password                   = var.aks_windows_admin_password
  tags                             = merge(var.common_tags, var.aks_tags)
  vnet_subnet_id                   = module.network.vnet_subnets[var.aks_subnet_index]
  sku_tier                         = var.aks_sku_tier
  api_auth_ips                     = var.api_auth_ips
  private_cluster                  = var.private_cluster
  enable_role_based_access_control = var.aks_enable_role_based_access_control
  rbac_aad_managed                 = var.aks_rbac_aad_managed
  rbac_aad_admin_group_object_ids  = var.aks_rbac_aad_admin_group_object_ids
  rbac_aad_client_app_id           = var.client_id
  rbac_aad_server_app_id           = var.client_id
  rbac_aad_server_app_secret       = var.client_secret
  default_node_pool                = var.default_node_pool
  additional_node_pools            = var.additional_node_pools
  addons                           = var.addons
  system_assigned_managed_identity = var.system_assigned_managed_identity
  network_profile                  = var.network_profile

  depends_on = [module.resgp, module.network]
}

module "ansible_provisioner" {
  source = "./modules/terraform-azure-ansible-provisioner"

  arguments = concat(var.arguments)
  envs      = concat(["resource_group_name=${module.resgp.res_group_name}", "aks_cluster_name=${module.aks.cluster_name}", "app_name=${var.project_name}-${var.environment}", "NAMESPACE=default", "subscription_id=${var.subscription_id}", "tenant_id=${var.tenant_id}", "client_id=${var.client_id}", "client_secret=${var.client_secret}"], var.envs)
  playbook  = var.playbook
  dry_run   = var.dry_run
}

module "sql" {
  source                                     = "./modules/terraform-azure-sql"
  resource_group_name                        = module.resgp.res_group_name
  environment                                = var.environment
  stack                                      = var.project_name
  location                                   = coalesce(var.network_location, var.common_resource_location, module.resgp.location)
  name_suffix                                = var.sql_name_suffix
  server_version                             = var.sql_server_version
  allowed_cidr_list                          = var.sql_allowed_cidr_list
  extra_tags                                 = merge(var.common_tags, var.sql_extra_tags)
  server_extra_tags                          = merge(var.common_tags, var.sql_server_extra_tags)
  databases_extra_tags                       = merge(var.common_tags, var.sql_databases_extra_tags)
  server_custom_name                         = var.sql_server_custom_name
  administrator_login                        = var.sql_administrator_login
  administrator_password                     = var.sql_administrator_password
  nb_database                                = var.sql_nb_database
  databases_collation                        = var.sql_databases_collation
  enable_advanced_data_security              = var.sql_enable_advanced_data_security
  enable_advanced_data_security_admin_emails = var.sql_enable_advanced_data_security_admin_emails
  advanced_data_security_additional_emails   = var.sql_advanced_data_security_additional_emails
  create_databases_users                     = var.sql_create_databases_users
  daily_backup_retention                     = var.sql_daily_backup_retention
  weekly_backup_retention                    = var.sql_weekly_backup_retention
  monthly_backup_retention                   = var.sql_monthly_backup_retention
  yearly_backup_retention                    = var.sql_yearly_backup_retention
  yearly_backup_time                         = var.sql_yearly_backup_time
  requested_service_objective_name           = var.sql_requested_service_objective_name
}
