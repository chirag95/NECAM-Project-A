output "backup_policy_id" {
  description = "the id of the backup policy created"
  value       = azurerm_backup_policy_vm.policy.id
}