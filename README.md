# Disaster_Recovery_3tier_Terraform-
Disaster_Recovery_3tier_Terraform 




module "rds" {
  source               = "./modules/rds"
  db_identifier        = "app-db"
  db_engine           = "mysql"
  db_instance_class   = "db.t3.micro"
  db_allocated_storage = 25
  db_name             = "test"
  db_username         = "admin"
  db_password         = "password123"  # Consider using AWS Secrets Manager
  db_security_group_id = module.security_group.security_group_id
  db_subnet_ids       = [module.network.private_subnet_ids[4], module.network.private_subnet_ids[5]]  # ✅ Fixed Reference
}

output "rds_name" {
  
  value = module.rds.rds_endpoint
}


# # Module: Load Balancers
module "alb" {
  source            = "./modules/load_balancers"
  frontend_alb_name = "frontend-alb"
  backend_alb_name  = "backend-alb"
  security_group_id = module.security_group.security_group_id
  public_subnet_ids = [module.network.public_subnet_ids[1], module.network.public_subnet_ids[0]]
  frontend_tg_name  = "frontend-tg"
  backend_tg_name   = "backend-tg"
  vpc_id            = module.network.vpc_id
}

# output "alb_front_dns_name" {
#   value = module.load_balancers.aws_lb.frontend_alb.arn
# }

# output "alb_backend_dns_name" {
#   value = module.load_balancers.aws_lb.backend_alb.arn
# }

module "launch_templates" {
  source              = "./modules/launch_templates"
  frontend_lt_name    = "frontend-lt"
  backend_lt_name     = "backend-lt"
  key_name            = "ramanikey"
  ami_id_frontend     = "ami-0c74c875f4df01539"
  ami_id_backend      = "ami-028bea3d2aaaef497"
  instance_type       = "t2.micro"
  frontend_user_data  = "frontend.sh"
  backend_user_data   = "backend.sh"
  security_group_id   = module.security_group.security_group_id
}



module "autoscaling" {
  source               = "./modules/asg"
  frontend_asg_name    = "frontend-asg"
  backend_asg_name     = "backend-asg"
  asg_min_size         = 1
  asg_max_size         = 3
  asg_desired_capacity = 1
  frontend_subnet_ids  = [module.network.private_subnet_ids[0], module.network.private_subnet_ids[1]]
  backend_subnet_ids   = [module.network.private_subnet_ids[2], module.network.private_subnet_ids[3]]
  frontend_tg_arn      = module.alb.frontend_tg_arn
  backend_tg_arn       = module.alb.backend_tg_arn
  frontend_lt_id        =  module.launch_templates.frontend_lt_id
  backend_lt_id = module.launch_templates.backend_lt_id

}

module "bastion" {
  source            = "./modules/bastion"
  ami_id            = "ami-04b4f1a9cf54c11d0"
  instance_type     = "t2.micro"
  key_name          = "ramanikey"
  public_subnet_id  = module.network.public_subnet_ids[0]
  security_group_id = module.security_group.security_group_id
}

output "jump_server" {
  value = module.bastion.bastion_public_ip
}

module "route53" {
  source              = "./modules/route53"
  vpc_id              = module.network.vpc_id
  rds_endpoint        = module.rds.rds_endpoint
  alb_dns_name        = module.alb.alb_backend_dns
  alb_front_dns_name = module.alb.alb_frontend_dns
}


module "acm" {
  source      = "./modules/acm"
  domain_name = "b15facebook.xyz"
  san_names   = ["*.b15facebook.xyz"]
}
