output "id" {
  description = "Output the object ID"
  value       = azurerm_firewall.az_firewall.id
}

output "name" {
  description = "Output the object name"
  value       = azurerm_firewall.az_firewall.name
}

output "object" {
  description = "Output the full object"
  value       = azurerm_firewall.az_firewall
}
