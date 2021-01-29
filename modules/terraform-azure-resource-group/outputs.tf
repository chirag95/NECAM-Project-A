output "res_group_id" {
  value = element(coalescelist(data.azurerm_resource_group.res_group.*.id, azurerm_resource_group.res_group.*.id, list("")), 0)
}

output "res_group_name" {
  value = element(coalescelist(data.azurerm_resource_group.res_group.*.name, azurerm_resource_group.res_group.*.name, list("")), 0)
}

output "location" {
  value = element(coalescelist(data.azurerm_resource_group.res_group.*.location, azurerm_resource_group.res_group.*.location, list("")), 0)
}
