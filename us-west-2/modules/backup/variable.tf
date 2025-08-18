variable "vault_name" {
  description = "Backup vault name"
  type        = string
}

variable "plan_name" {
  description = "Backup plan name"
  type        = string
}

variable "rule_name" {
  description = "Backup rule name"
  type        = string
}

variable "source_region" {
  description = "Source region where backups will be created"
  type        = string
  default     = "us-east-1"
}

variable "destination_region" {
  description = "Destination region where backups will be copied"
  type        = string
  default     = "us-west-2"
}

variable "resource_assignments" {
  description = "List of EC2 instance ARNs to back up"
  type        = list(string)
}
