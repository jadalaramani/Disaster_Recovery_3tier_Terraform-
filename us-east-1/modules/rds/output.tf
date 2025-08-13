output "rds_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.db.id
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.db.endpoint
}

output "rds_subnet_group" {
  description = "The name of the RDS subnet group"
  value       = aws_db_subnet_group.rds_subnet_group.name
}

output "db_arn" {
  value = var.replicate_source_db == "" ? aws_db_instance.primary[0].arn : aws_db_instance.replica[0].arn
}
