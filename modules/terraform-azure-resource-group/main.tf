locals {
  location            = element(coalescelist(data.azurerm_resource_group.res_group.*.location, azurerm_resource_group.res_group.*.location, list(var.location)), 0)
  resource_group_name = element(coalescelist(data.azurerm_resource_group.res_group.*.name, azurerm_resource_group.res_group.*.name, list("")), 0)
  default_tags = {
    env   = var.environment
    stack = var.stack
  }  
}

data "azurerm_resource_group" "res_group" {
  count = var.create_resource_group == true ? 0 : 1

  name = var.name
}

resource "azurerm_resource_group" "res_group" {
  count = var.create_resource_group ? 1 : 0

  name     = "${var.stack}-${var.environment}-resgp${var.name}"
  location = var.location

  tags = merge(map("Name", "${var.stack}-${var.environment}-resgp${var.name}"), local.default_tags, var.tags)
}
