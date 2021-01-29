locals {
  retention_weekly  = var.retention_weekly != null ? [var.retention_weekly] : []
  retention_monthly = var.retention_weekly != null ? [var.retention_monthly] : []
  retention_yearly  = var.retention_weekly != null ? [var.retention_yearly] : []
}


resource "azurerm_recovery_services_vault" "rvault" {
  name                = "${var.stack}-${var.environment}-recovery-vault${var.recovery_vault_name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.recovery_vault_sku
}

resource "azurerm_backup_policy_vm" "policy" {
  name                = "${var.stack}-${var.environment}-recovery-vault-${var.recovery_vault_name_suffix}-policy" 
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.rvault.name

  timezone = var.timezone

  backup {
    frequency = lookup(var.backup, "frequency", "Daily")
    time      = lookup(var.backup, "time", "23:00")
    weekdays  = lookup(var.backup, "weekdays", null)
  }

  retention_daily {
    count = var.retention_daily_count
  }

  dynamic "retention_weekly" {
    for_each = local.retention_weekly
    content {
      count    = lookup(retention_weekly.value, "count")
      weekdays = lookup(retention_weekly.value, "weekdays")
    }
  }

  dynamic "retention_monthly" {
    for_each = local.retention_monthly
    content {
      count    = lookup(retention_monthly.value, "count")
      weekdays = lookup(retention_monthly.value, "weekdays")
      weeks    = lookup(retention_monthly.value, "weeks")
    }
  }

  dynamic "retention_yearly" {
    for_each = local.retention_yearly
    content {
      count    = lookup(var.retention_yearly, "count")
      weekdays = lookup(var.retention_yearly, "weekdays")
      weeks    = lookup(var.retention_yearly, "weeks")
      months   = lookup(var.retention_yearly, "months")
    }
  }
}

resource "azurerm_backup_protected_vm" "recovery_vault_backup_enable" {
  count = var.vm_count

  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.rvault.name
  source_vm_id        = element(var.vm_ids, count.index)
  backup_policy_id    = azurerm_backup_policy_vm.policy.id
}
