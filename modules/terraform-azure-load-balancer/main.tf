locals {
  name_prefix                                 = var.prefix != "" ? "${var.stack}-${var.environment}-${var.prefix}" : "${var.stack}-${var.environment}"
  lb_name                                     = "${local.name_prefix}-lb"
  frontend_name_ipv4                          = "${local.lb_name}-frontent-ipv4${var.frontend_name_suffix}"
  default_tags = {
    env   = var.environment
    stack = var.stack
  }
}

data "azurerm_resource_group" "azlb" {
  name = var.resource_group_name
}

resource "azurerm_public_ip" "azlb" {
  count               = var.type == "public" ? 1 : 0
  sku                 = var.public_ip_sku
  location            = coalesce(var.location, data.azurerm_resource_group.azlb.location)
  name                = "${local.lb_name}-publicIP-v4"
  resource_group_name = data.azurerm_resource_group.azlb.name
  allocation_method   = var.allocation_method
  tags                = merge(local.default_tags, var.ipv4_tags)
}

resource "azurerm_lb" "azlb" {
  name                = local.lb_name
  resource_group_name = data.azurerm_resource_group.azlb.name
  location            = coalesce(var.location, data.azurerm_resource_group.azlb.location)
  sku                 = var.lb_sku
  tags                = merge(local.default_tags, var.tags)

  frontend_ip_configuration {
    name                          = local.frontend_name_ipv4
    public_ip_address_id          = var.type == "public" ? join("", azurerm_public_ip.azlb.*.id) : ""
    subnet_id                     = var.type == "public" ? "" : var.frontend_subnet_id
    private_ip_address            = var.frontend_private_ip_address
    private_ip_address_allocation = var.frontend_private_ip_address_allocation
  }

}

resource "azurerm_lb_backend_address_pool" "azlb" {
  name                = "${local.lb_name}-BackEndAddressPool"
  resource_group_name = data.azurerm_resource_group.azlb.name
  loadbalancer_id     = azurerm_lb.azlb.id
}

resource "azurerm_lb_nat_rule" "azlb" {
  count                          = length(var.remote_port)
  name                           = "${local.lb_name}-ipv4-rule-${count.index}"
  resource_group_name            = data.azurerm_resource_group.azlb.name
  loadbalancer_id                = azurerm_lb.azlb.id
  protocol                       = "tcp"
  frontend_port                  = "5000${count.index + 1}"
  backend_port                   = element(var.remote_port[element(keys(var.remote_port), count.index)], 1)
  frontend_ip_configuration_name = local.frontend_name_ipv4
}

resource "azurerm_lb_probe" "azlb" {
  count               = length(var.lb_probe)
  name                = "${local.lb_name}-${element(keys(var.lb_probe), count.index)}"
  resource_group_name = data.azurerm_resource_group.azlb.name
  loadbalancer_id     = azurerm_lb.azlb.id
  protocol            = element(var.lb_probe[element(keys(var.lb_probe), count.index)], 0)
  port                = element(var.lb_probe[element(keys(var.lb_probe), count.index)], 1)
  interval_in_seconds = var.lb_probe_interval
  number_of_probes    = var.lb_probe_unhealthy_threshold
  request_path        = element(var.lb_probe[element(keys(var.lb_probe), count.index)], 2)
}

resource "azurerm_lb_rule" "azlb" {
  count                          = length(var.lb_port)
  name                           = "${local.lb_name}-${element(keys(var.lb_port), count.index)}"
  resource_group_name            = data.azurerm_resource_group.azlb.name
  loadbalancer_id                = azurerm_lb.azlb.id
  protocol                       = element(var.lb_port[element(keys(var.lb_port), count.index)], 1)
  frontend_port                  = element(var.lb_port[element(keys(var.lb_port), count.index)], 0)
  backend_port                   = element(var.lb_port[element(keys(var.lb_port), count.index)], 2)
  frontend_ip_configuration_name = local.frontend_name_ipv4
  enable_floating_ip             = var.enable_floating_ip
  backend_address_pool_id        = azurerm_lb_backend_address_pool.azlb.id
  idle_timeout_in_minutes        = 5
  probe_id                       = element(azurerm_lb_probe.azlb.*.id, count.index)
}