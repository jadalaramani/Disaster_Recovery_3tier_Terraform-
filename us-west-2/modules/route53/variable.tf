variable "vpc_id" {
  description = "VPC ID for private hosted zone"
  type        = string
}

variable "rds_private_zone_name" {
  description = "The name of the private hosted zone for RDS"
  type        = string
  default     = "rds.com"
}


variable "alb_record_name" {
  description = "The record name for the backend ALB"
  type        = string
  default     = "api.b15catsvsdogs.xyz"
}

variable "alb_dns_name" {
  description = "The DNS name of the backend ALB"
  type        = string
}
variable "alb_zone_id" {
  type = string
}


