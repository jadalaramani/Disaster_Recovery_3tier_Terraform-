resource "aws_route53_health_check" "backend" {
  fqdn              = var.backend_alb_dns
  port              = 80
  type              = "HTTP"
  resource_path     = var.health_check_path
  request_interval  = 30
  failure_threshold = 3
  #regions           = ["us-east-1", "us-west-2"]

  tags = {
    Name = "backend-alb-health-check"
  }
}

variable "backend_alb_dns" {
  description = "DNS name of the backend ALB"
  type        = string
}

variable "health_check_path" {
  description = "Path for the backend health check"
  type        = string
  default     = "/health"
}

output "backend_healthcheck_id" {
  description = "ID of the Route53 health check for backend ALB"
  value       = aws_route53_health_check.backend.id
}
