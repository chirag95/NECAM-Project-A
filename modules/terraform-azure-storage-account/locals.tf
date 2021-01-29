locals {
  sas_token         = var.generate_storage_sas_token ? jsondecode(join("", regex("\"sastoken\":(\".*\")", jsonencode(data.external.generate_storage_sas_token)))) : null
  sas_uri_container = var.generate_storage_sas_token && var.storage_container != "" ? "${join("", azurerm_storage_account.sa.primary_blob_endpoint)}${var.storage_container}${local.sas_token}" : null
}
