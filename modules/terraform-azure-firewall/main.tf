locals {
  firewall_name = "${var.stack}-${var.environment}-firewall${var.firewall_suffix}"
  default_tags = {
    env   = var.environment
    stack = var.stack
  }
}

# Create a subnet for Azure Firewall
resource "azurerm_subnet" "AzureFirewallSubnet" {
  name = "AzureFirewallSubnet" # mandatory name -do not rename-
  address_prefixes     = [var.azure_firewall_subnet_address_prefix]
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

# Create the public ip for Azure Firewall
resource "azurerm_public_ip" "azure_firewall_pip" {
  name                = "${local.firewall_name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku
  tags                = merge(local.default_tags, var.tags)
}

# Create the Azure Firewall
resource "azurerm_firewall" "az_firewall" {
  depends_on          = [azurerm_public_ip.azure_firewall_pip]
  name                = local.firewall_name
  resource_group_name = var.resource_group_name
  location            = var.location
  ip_configuration {
    name                 = "${local.firewall_name}-${var.location}-config"
    subnet_id            = azurerm_subnet.AzureFirewallSubnet.id
    public_ip_address_id = azurerm_public_ip.azure_firewall_pip.id
  }

  tags = merge(local.default_tags,var.tags)
}


