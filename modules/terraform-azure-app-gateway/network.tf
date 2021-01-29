module "azure-network-subnet" {

  count  = var.create_subnet ? 1 : 0
  source = "../terraform-azure-subnet"

  environment         = var.environment
  stack               = var.stack
  resource_group_name = var.subnet_resource_group_name != "" ? var.subnet_resource_group_name : var.resource_group_name

  virtual_network_name = var.virtual_network_name

  custom_subnet_names = var.create_subnet ? local.subnet_name : []
  subnet_cidr_list    = var.create_subnet ? [var.subnet_cidr] : []

  network_security_group_ids = local.nsg_ids #dependent on "azure-network-security-group"

  route_table_ids = var.create_subnet ? var.route_table_ids : {}
}

module "azure-network-security-group" {
  source = "../terraform-azure-network-security-group"

  environment         = var.environment
  stack               = var.stack
  resource_group_name = var.subnet_resource_group_name != "" ? var.subnet_resource_group_name : var.resource_group_name
  location            = var.location

  custom_network_security_group_names = var.custom_nsg_name != "" && var.custom_nsg_name != null ? [var.custom_nsg_name] : [""]
  network_security_group_instances    = var.create_nsg ? 1 : 0

  extra_tags = merge(local.default_tags, var.extra_tags)
}

resource "azurerm_network_security_rule" "web" {
  count = var.create_nsg && var.create_nsg_https_rule ? 1 : 0

  name = local.nsr_https_name

  resource_group_name         = var.subnet_resource_group_name != "" ? var.subnet_resource_group_name : var.resource_group_name
  network_security_group_name = module.azure-network-security-group.network_security_group_name[0]

  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range       = "*"
  destination_port_ranges = ["443"]

  source_address_prefix      = var.nsr_https_source_address_prefix != "*" ? var.nsr_https_source_address_prefix : "*"
  destination_address_prefix = "*"
}


resource "azurerm_network_security_rule" "allow_health_probe_app_gateway" {
  count = var.create_nsg && var.create_nsg_healthprobe_rule ? 1 : 0

  name = local.nsr_healthcheck_name

  resource_group_name         = var.subnet_resource_group_name != "" ? var.subnet_resource_group_name : var.resource_group_name
  network_security_group_name = module.azure-network-security-group.network_security_group_name[0]

  priority  = 101
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range       = "*"
  destination_port_ranges = ["65200-65535"]

  source_address_prefix      = "Internet"
  destination_address_prefix = "*"
}
