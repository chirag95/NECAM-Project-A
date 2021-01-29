locals {
  name_prefix  = var.name_prefix != "" ? replace(var.name_prefix, "/[a-z0-9]$/", "$0-") : ""
  default_name = var.name_prefix != "" ? "${var.stack}-${var.environment}-${local.name_prefix}" : "${var.stack}-${var.environment}"

  appgw_name = "${local.default_name}-appgw"

  subnet_name = ["${local.default_name}-appgw-subnet"]

  nsg_ids = var.create_nsg ? {
    element(local.subnet_name, 0) = join("", module.azure-network-security-group.network_security_group_id)
  } : {}

  nsr_https_name       = "${local.default_name}-appgw-https-nsr"
  nsr_healthcheck_name = "${local.default_name}-appgw-healthcheck-nsr"

  ip_name  = "${local.default_name}-appgw-pubip"
  ip_label = "${local.default_name}-appgw-pubip"

  frontend_ip_configuration_name = "${local.default_name}-appgw-frontipconfig"

  gateway_ip_configuration_name = "${local.default_name}-appgwipconfig"
  diag_settings_name            = "${local.default_name}-appgw-diag-settings"

  enable_waf = var.sku == "WAF_v2" ? true : false

  default_tags = {
    env   = var.environment
    stack = var.stack
  }
}
