# Private Hosted Zone for RDS
resource "aws_route53_zone" "rds_private" {
  name = var.rds_private_zone_name
  vpc {
    vpc_id = var.vpc_id
  }
}
# # Public Hosted Zone for b15facebook.xyz
# resource "aws_route53_zone" "public_zone" {
#   name = var.public_zone_name
# }
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

#     set_identifier = "backend-primary"

#     failover_routing_policy {
#     type = "PRIMARY"
#   }
#   health_check_id = var.health_check_id
# }

# resource "aws_route53_record" "alb_backend" {
#   zone_id = data.aws_route53_zone.public_zone.id
#   name    = var.alb_record_name
#   type    = "A"
#   set_identifier = "backend-primary"

#   alias {
#     name                   = var.alb_dns_name   # ALB DNS
#     zone_id                =  var.alb_zone_id   # ALB Hosted Zone ID (not Route53 zone)
#     evaluate_target_health = true
#   }

#   failover_routing_policy {
#     type = "PRIMARY"
#   }

#   health_check_id = var.health_check_id
# }




resource "aws_route53_record" "alb_frontend" {
  zone_id = "Z03144592RNZ1O5HJMDC4"
  name    = var.alb_dns_frontend_record
  type    = "CNAME"
  ttl     = 300
  records = [var.alb_front_dns_name]
}
