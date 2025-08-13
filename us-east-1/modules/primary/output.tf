output "db_arn" {
  description = "The ARN of the DB instance"
  value       = var.replicate_source_db == "" ? aws_db_instance.primary[0].arn : aws_db_instance.replica[0].arn
}

output "db_identifier_out" {
  description = "The DB identifier"
  value       = var.replicate_source_db == "" ? aws_db_instance.primary[0].identifier : aws_db_instance.replica[0].identifier
}
