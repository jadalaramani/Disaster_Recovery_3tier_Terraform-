output "backup_vault_name" {
  value = aws_backup_vault.this.name
}

output "backup_plan_id" {
  value = aws_backup_plan.this.id
}
