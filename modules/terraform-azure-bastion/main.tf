#----------------------------------------------------------
# Resource Group, Random Resources
#----------------------------------------------------------
locals {
  bastion_name = "${var.stack}-${var.environment}-bastion${var.azure_bastion_service_name_suffix}"
  default_tags = {
    env   = var.environment
    stack = var.stack
  }
}

resource "random_string" "str" {
  length  = 6
  special = false
  upper   = false
  keepers = {
    domain_name_label = local.bastion_name
  }
}

#-----------------------------------------------------------------------
# Subnets Creation for Azure Bastion Service - at least /27 or larger.
#-----------------------------------------------------------------------
resource "azurerm_subnet" "abs_snet" {
  count                = var.azure_bastion_subnet_address_prefix != null ? 1 : 0
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.azure_bastion_subnet_address_prefix
}

#---------------------------------------------
# Public IP for Azure Bastion Service
#---------------------------------------------
resource "azurerm_public_ip" "pip" {
  name                = lower("${local.bastion_name}-${var.location}-pip")
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku
  domain_name_label   = var.domain_name_label != null ? var.domain_name_label : format("gw%s%s", lower(replace(local.bastion_name, "/[[:^alnum:]]/", "")), random_string.str.result)
  tags                = merge({ "ResourceName" = lower("${local.bastion_name}-${var.location}-pip") }, var.tags, local.default_tags )
}

#---------------------------------------------
# Azure Bastion Service host
#---------------------------------------------
resource "azurerm_bastion_host" "main" {
  name                = local.bastion_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "${local.bastion_name}-network"
    subnet_id            = azurerm_subnet.abs_snet.0.id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

