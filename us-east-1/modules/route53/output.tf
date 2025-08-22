output "rds_private_zone_id" {
  description = "The ID of the private hosted zone for RDS"
  value       = aws_route53_zone.rds_private.zone_id
}



# output "alb_record_fqdn" {
#   description = "The fully qualified domain name (FQDN) for the ALB backend record"
#   value       = aws_route53_record.alb_backend.fqdn
# }


# output "alb_zone_id" {
#   value = aws_route53_record.alb_backend.zone_id
# }