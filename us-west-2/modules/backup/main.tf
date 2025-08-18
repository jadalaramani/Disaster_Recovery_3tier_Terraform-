# ---------------- Plan ----------------
resource "aws_backup_plan" "this" {
  name = var.plan_name

  rule {
    rule_name         = var.rule_name
    target_vault_name = aws_backup_vault.this.name
    schedule          = "cron(0 12 * * ? *)" # Daily at 12:00 UTC (example)

    lifecycle {
      delete_after = 30 # Keep backups for 30 days
    }

    copy_action {
      destination_vault_arn = "arn:aws:backup:${var.destination_region}:${data.aws_caller_identity.current.account_id}:backup-vault:Default"
    }
  }
}



# data "aws_iam_role" "backup_role" {
#   name = "AWSBackupDefaultServiceRole"
# }

# ---------------- Assignment ----------------


# Use existing AWS Backup service role
data "aws_iam_role" "backup_role" {
  name = "AWSBackupDefaultServiceRole"
}

resource "aws_backup_vault" "this" {
  name = var.vault_name
}


resource "aws_backup_selection" "this" {
  iam_role_arn = data.aws_iam_role.backup_role.arn
  name         = "${var.plan_name}-assignment"
  plan_id      = aws_backup_plan.this.id

  resources = var.resource_assignments
}

data "aws_caller_identity" "current" {}





