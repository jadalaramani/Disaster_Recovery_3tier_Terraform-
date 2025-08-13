variable "replicate_source_db" {
  description = "ARN of the source DB for read replica. Leave empty for primary DB."
  type        = string
  default     = ""
}

variable "db_identifier" {
  type        = string
}

variable "db_engine" {
  type        = string
}

variable "db_instance_class" {
  type        = string
}

variable "db_allocated_storage" {
  type        = number
  default     = null
}

variable "db_name" {
  type        = string
  default     = null
}

variable "db_username" {
  type        = string
  default     = null
}

variable "db_password" {
  type        = string
  default     = null
}

variable "db_security_group_id" {
  type = string
}

variable "db_subnet_ids" {
  type = list(string)
}

variable "backup_retention_period" {
  type    = number
  default = 7
}
