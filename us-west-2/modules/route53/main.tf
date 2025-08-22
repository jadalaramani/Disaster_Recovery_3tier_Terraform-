# Private Hosted Zone for RDS
resource "aws_route53_zone" "rds_private" {
  name = var.rds_private_zone_name
  vpc {
    vpc_id = var.vpc_id
  }
}

data "aws_route53_zone" "public_zone" {
  name = "b15catsvsdogs.xyz"
}
# resource "aws_route53_record" "alb_backend" {
#   #zone_id = "Z03144592RNZ1O5HJMDC4"
#   zone_id = data.aws_route53_zone.public_zone.id
#   name    = var.alb_record_name
#   type    = "A"
#   ttl     = 300
#   records = [var.alb_dns_name]

#     set_identifier = "backend-secondary"

#     failover_routing_policy {
#     type = "SECONDARY"
#   }
# }

resource "aws_route53_record" "alb_backend_secondary" {
  zone_id = data.aws_route53_zone.public_zone.id
  name    = var.alb_record_name
  type    = "A"
  set_identifier = "backend-secondary"

  alias {
    name                   = var.alb_dns_name   # ALB DNS from us-west-2
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }

  failover_routing_policy {
    type = "SECONDARY"
  }
}

