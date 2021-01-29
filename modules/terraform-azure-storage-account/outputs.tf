output "id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.sa.id
}

output "name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.sa.name
}

output "primary_connection_string" {
  description = "The primary connection string for the storage account."
  value       = azurerm_storage_account.sa.primary_connection_string
}

output "primary_access_key" {
  description = "The primary access key for the storage account."
  value       = azurerm_storage_account.sa.primary_access_key
}

output "storage_account_sas_token" {
  description = "SAS Token generated for access on Storage Account."
  value       = local.sas_token
  sensitive   = true
}

output "storage_account_sas_container_uri" {
  description = "SAS URI generated for access on Storage Account Container."
  value       = local.sas_uri_container
  sensitive   = true
}
