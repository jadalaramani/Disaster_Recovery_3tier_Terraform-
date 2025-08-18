# ---------------- Vault ----------------
resource "aws_backup_vault" "this" {
  name = var.vault_name
}

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

data "aws_caller_identity" "current" {}

# ---------------- Assignment ----------------
resource "aws_backup_selection" "this" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "${var.plan_name}-assignment"
  plan_id      = aws_backup_plan.this.id

  resources = var.resource_assignments
}

# ---------------- IAM Role ----------------
resource "aws_iam_role" "backup_role" {
  name = "AWSBackupDefaultServiceRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "backup.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backup_attach" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}
