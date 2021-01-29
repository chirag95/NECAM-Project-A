locals {
  default_tags = {
    env   = var.environment
    stack = var.stack
  }

  name_suffix = var.name_suffix != "" ? replace(var.name_suffix, "/[a-z0-9]$/", "$0-") : ""

  server_name = coalesce(
    var.server_custom_name,
    "${var.stack}-${var.environment}-sql${local.name_suffix}",
  )
 
  database_name_prefix = "${var.stack}-${var.environment}-database${local.name_suffix}"
  log_categories = [
    "SQLInsights",
    "AutomaticTuning",
    "QueryStoreRuntimeStatistics",
    "QueryStoreWaitStatistics",
    "Errors",
    "DatabaseWaitStatistics",
    "Timeouts",
    "Blocks",
    "Deadlocks",
    "Audit",
    "SQLSecurityAuditEvents",
  ]
}
