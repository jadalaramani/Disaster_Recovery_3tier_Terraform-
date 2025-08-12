variable "db_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
  # default     = "app-db"
}

variable "db_engine" {
  description = "Database engine type"
  type        = string
  # default     = "mysql"
}

variable "db_instance_class" {
  description = "Instance type for the RDS database"
  type        = string
  # default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for the database (in GB)"
  type        = number
  # default     = 25
}

variable "db_name" {
  description = "The name of the initial database"
  type        = string
  # default     = "test"
}

variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
  # default     = "admin"
}

variable "db_password" {
  description = "Master password for the RDS instance"
  type        = string
  sensitive   = true
  # default     = "password123"  # Consider using environment variables or AWS Secrets Manager instead
}

variable "db_security_group_id" {
  description = "Security group ID for the RDS instance"
  type        = string
}

variable "db_subnet_ids" {
  description = "List of subnet IDs for the RDS subnet group"
  type        = list(string)
}

variable "source_db_arn" {
  type    = string
  default = ""
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "preferred_backup_window" {
  type    = string
  default = "03:00-04:00"
}
variable "replicate_source_db" {
  description = "ARN or ID of the source DB instance if creating a read replica"
  type        = string
  default     = null
}
