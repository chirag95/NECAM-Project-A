resource "azurerm_sql_server" "server" {
  name = local.server_name

  location            = var.location
  resource_group_name = var.resource_group_name

  version                      = var.server_version
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_password

  tags = merge(local.default_tags, var.extra_tags, var.server_extra_tags)
}

resource "azurerm_sql_firewall_rule" "firewall_rule" {
  count = length(var.allowed_cidr_list)

  name                = "rule-${count.index}"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.server.name

  start_ip_address = cidrhost(var.allowed_cidr_list[count.index], 0)
  end_ip_address   = cidrhost(var.allowed_cidr_list[count.index], -1)
}

resource "azurerm_sql_database" "db" {
  count = var.nb_database 

  name                = "${local.database_name_prefix}${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  server_name = azurerm_sql_server.server.name
  collation   = var.databases_collation
  read_scale = var.db_read_scale
  requested_service_objective_name = var.requested_service_objective_name

  threat_detection_policy {
    email_account_admins = var.enable_advanced_data_security_admin_emails ? "Enabled" : "Disabled"
    email_addresses      = var.advanced_data_security_additional_emails
    state                = var.enable_advanced_data_security ? "Enabled" : "Disabled"
  }

  tags = merge(local.default_tags, var.extra_tags, var.databases_extra_tags)
}
