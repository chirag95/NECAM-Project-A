locals {
  if_ddos_enabled = var.create_ddos_plan ? [{}] : []
  ddos_plan_name  = "${var.stack}-${var.environment}-ddos${var.ddos_plan_name_suffix}"
  default_tags = {
    env   = var.environment
    stack = var.stack
  }
}

resource "azurerm_network_ddos_protection_plan" "ddos" {
  count               = var.create_ddos_plan ? 1 : 0
  name                = local.ddos_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge({ "Name" = format("%s", local.ddos_plan_name) }, var.ddos_resource_tags, local.default_tags)
}


resource "azurerm_virtual_network" "vnet" {
  name                = "${var.stack}-${var.environment}-vnet${var.vnet_name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = merge(local.default_tags, var.tags)


  dynamic "ddos_protection_plan" {
    for_each = local.if_ddos_enabled

    content {
      id     = azurerm_network_ddos_protection_plan.ddos[0].id
      enable = true
    }
  }
}

resource "azurerm_subnet" "subnet" {
  count                = length(var.subnet_prefixes)
  name                 = "${var.stack}-${var.environment}-subnet-${count.index}${var.subnet_name_suffix}"
  resource_group_name  = var.resource_group_name
  address_prefixes     = [var.subnet_prefixes[count.index]]
  virtual_network_name = azurerm_virtual_network.vnet.name
}

module "bastion" {
  count                               = var.bastion_config.enable ? 1 : 0
  source                              = "../terraform-azure-bastion"
  environment                         = var.environment
  stack                               = var.stack
  resource_group_name                 = var.resource_group_name
  location                            = var.location
  virtual_network_name                = azurerm_virtual_network.vnet.name
  azure_bastion_service_name_suffix   = var.bastion_config.azure_bastion_service_name_suffix
  azure_bastion_subnet_address_prefix = var.bastion_config.azure_bastion_subnet_address_prefix
  public_ip_allocation_method         = var.bastion_config.public_ip_allocation_method
  public_ip_sku                       = var.bastion_config.public_ip_sku
  domain_name_label                   = var.bastion_config.domain_name_label
  tags                                = merge(local.default_tags, var.bastion_config.tags)
  depends_on                          = [azurerm_virtual_network.vnet]
}

module "firewall" {
  count                                = var.firewall_config.enable ? 1 : 0
  source                               = "../terraform-azure-firewall"
  resource_group_name                  = var.resource_group_name
  virtual_network_name                 = azurerm_virtual_network.vnet.name
  firewall_suffix                      = var.firewall_config.suffix
  environment                          = var.environment
  stack                                = var.stack
  location                             = var.location
  public_ip_allocation_method          = var.firewall_config.public_ip_allocation_method
  public_ip_sku                        = var.firewall_config.public_ip_sku
  azure_firewall_subnet_address_prefix = var.firewall_config.subnet_address_prefix
  tags                                 = merge(local.default_tags, var.firewall_config.tags)
  depends_on                           = [azurerm_virtual_network.vnet]
}
