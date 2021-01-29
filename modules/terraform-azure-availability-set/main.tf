resource "azurerm_availability_set" "vm" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  platform_fault_domain_count  = var.platform_fault_domain_count
  platform_update_domain_count = var.platform_update_domain_count
  managed                      = var.managed
  tags                         = var.tags

}
