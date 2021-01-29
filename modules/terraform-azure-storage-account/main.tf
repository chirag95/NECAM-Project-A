resource "azurerm_storage_account" "sa" {
  name                = format("diag%s",lower(replace(var.storage_account_name_suffix, "/[[:^alnum:]]/", "")))
  resource_group_name = var.resource_group_name
  location            = var.location
  account_tier             = element(split("_", var.diagnostics_storage_account_type), 0)
  account_replication_type = element(split("_", var.diagnostics_storage_account_type), 1)
  tags = var.tags
}

data "external" "generate_storage_sas_token" {
  count = var.generate_storage_sas_token ? 1 : 0

  program = ["bash", "${path.module}/files/script_sas_token.sh"]

  query = {
    storage_account_name      = azurerm_storage_account.sa.name        
    storage_connection_string = azurerm_storage_account.sa.primary_connection_string
    storage_container         = var.storage_container
    token_expiry              = var.sas_token_expiry
    services                  = var.services
    resources_types           = var.resources_types
    permissions_account       = var.permissions_account
    permissions_container     = var.permissions_container
  }
}
