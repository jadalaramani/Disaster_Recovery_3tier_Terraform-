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


output "db_identifier_out" {
  description = "The DB identifier"
  value       = aws_db_instance.db.identifier
}

output "db_arn" {
  description = "ARN of the primary RDS instance"
  value       = aws_db_instance.db.arn
}
