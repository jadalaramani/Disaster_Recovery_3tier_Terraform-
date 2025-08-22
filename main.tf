# Primary region provider
provider "aws" {
  alias  = "primary"
  region = "us-east-1"
}

# Secondary region provider
provider "aws" {
  alias  = "secondary"
  region = "us-west-2"
  
}

module "network" {
  source = "./us-east-1/modules/network"

  vpc_cidr =  "170.20.0.0/16"
  
   public_subnets = [  
    { cidr = "170.20.1.0/24", az = "us-east-1a" },
    { cidr = "170.20.2.0/24", az = "us-east-1b" }
   ]

   private_subnets =  [
    { cidr = "170.20.3.0/24", az = "us-east-1a" },
    { cidr = "170.20.4.0/24", az = "us-east-1b" },
    { cidr = "170.20.5.0/24", az = "us-east-1a" },
    { cidr = "170.20.6.0/24", az = "us-east-1b" },
    { cidr = "170.20.7.0/24", az = "us-east-1a" },
    { cidr = "170.20.8.0/24", az = "us-east-1b" }
  ]

}

output "vpc_output_from_nwmodule" {
  
  value = module.network.vpc_id
}

# # Module: Security Groups
module "security_group" {
  source              = "./us-east-1/modules/security"
  vpc_id             = module.network.vpc_id
  sg_name            = "MAIN-security-group"
  ingress_from_port  = 0
  ingress_to_port    = 0
  ingress_protocol   = "-1"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_from_port   = 0
  egress_to_port     = 0
  egress_protocol    = "-1"
  egress_cidr_blocks = ["0.0.0.0/0"]
}

output "security_group_id" {
value = module.security_group.security_group_id
}

# Primary RDS
module "rds" {
  source               = "./us-east-1/modules/primary"
   create_primary     = true
  create_replica     = false
  providers = {
    aws = aws.primary
     
  }
  db_identifier        = "app-db"
  db_engine            = "mysql"
  db_instance_class    = "db.t3.micro"
  db_allocated_storage = 25
  db_name              = "test"
  db_username          = "admin"
  db_password          = "password123"
  db_security_group_id = module.security_group.security_group_id
  db_subnet_ids        = [
    module.network.private_subnet_ids[4],
    module.network.private_subnet_ids[5]
  ]
  backup_retention_period = 7
  
}

# # Module: Primary Load Balancers
module "alb" {
  source            = "./us-east-1/modules/load_balancers"
  frontend_alb_name = "frontend-alb"
  backend_alb_name  = "backend-alb"
  security_group_id = module.security_group.security_group_id
  public_subnet_ids = [module.network.public_subnet_ids[1], module.network.public_subnet_ids[0]]
  frontend_tg_name  = "frontend-tg"
  backend_tg_name   = "backend-tg"
  vpc_id            = module.network.vpc_id
}

## Module: Lauch Template
module "launch_templates" {
  source              = "./us-east-1/modules/launch_templates"
  frontend_lt_name    = "frontend-lt"
  backend_lt_name     = "backend-lt"
  key_name            = "ramanikey"
  ami_id_frontend     = "ami-0eec7485a34edc3b8"
  ami_id_backend      = "ami-0084f9ebbb4f07bcd"
  instance_type       = "t2.micro"
  frontend_user_data  = "frontend.sh"
  backend_user_data   = "backend.sh"
  security_group_id   = module.security_group.security_group_id

}

module "autoscaling" {
  source               = "./us-east-1/modules/asg"
  frontend_asg_name    = "frontend-asg"
  backend_asg_name     = "backend-asg"
  asg_min_size         = 1
  asg_max_size         = 1
  asg_desired_capacity = 1
  frontend_subnet_ids  = [module.network.private_subnet_ids[0], module.network.private_subnet_ids[1]]
  backend_subnet_ids   = [module.network.private_subnet_ids[2], module.network.private_subnet_ids[3]]
  frontend_tg_arn      = module.alb.frontend_tg_arn
  backend_tg_arn       = module.alb.backend_tg_arn
  frontend_lt_id        =  module.launch_templates.frontend_lt_id
  backend_lt_id = module.launch_templates.backend_lt_id

}

module "bastion" {
  source            = "./us-east-1/modules/bastion"
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
  source              = "./us-east-1/modules/route53"
  vpc_id              = module.network.vpc_id
  alb_dns_name        = module.alb.alb_backend_dns
  alb_front_dns_name = module.alb.alb_frontend_dns
  alb_zone_id = module.alb.alb_backend_zone_id
  health_check_id =  module.backend_healthcheck.backend_healthcheck_id
}

module "backend_healthcheck" {
  source = "./us-east-1/modules/healthcheck"

  backend_alb_dns =  module.alb.alb_backend_dns
  #health_check_path = "/health"
}


##################Secondary region#################################

###Secondary_network

module "secondary_network" {
  source = "./us-west-2/modules/network"
    providers = {
    aws = aws.secondary
  }
  vpc_cidr =  "170.21.0.0/16"
  
   public_subnets = [  
    { cidr = "170.21.1.0/24", az = "us-west-2a" },
    { cidr = "170.21.2.0/24", az = "us-west-2b" }
   ]

   private_subnets =  [
    { cidr = "170.21.3.0/24", az = "us-west-2a" },
    { cidr = "170.21.4.0/24", az = "us-west-2b" },
    { cidr = "170.21.5.0/24", az = "us-west-2a" },
    { cidr = "170.21.6.0/24", az = "us-west-2b" },
    { cidr = "170.21.7.0/24", az = "us-west-2a" },
    { cidr = "170.21.8.0/24", az = "us-west-2b" }
  ]
}

# # Seconadry Security Groups
module "secondary_security_group" {
  providers = {
    aws = aws.secondary
  }
  source              = "./us-west-2/modules/security"
  vpc_id             = module.secondary_network.vpc_id
  sg_name            = "MAIN-security-group"
  ingress_from_port  = 0
  ingress_to_port    = 0
  ingress_protocol   = "-1"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_from_port   = 0
  egress_to_port     = 0
  egress_protocol    = "-1"
  egress_cidr_blocks = ["0.0.0.0/0"]
}

#####Secondary rds(Replica)

module "secondary_rds" {
  source               = "./us-east-1/modules/primary"
   create_primary     = false
  create_replica     = true
    providers = {
    aws = aws.secondary
  }
  db_identifier        = "app-db-replica"
  db_engine            = "mysql"

  replicate_source_db  = module.rds.db_arn
  db_instance_class    = "db.t3.micro"
  db_security_group_id = module.secondary_security_group.security_group_id
  db_subnet_ids        = [
    module.secondary_network.private_subnet_ids[4],
    module.secondary_network.private_subnet_ids[5]
  ]
  backup_retention_period = 7
}

#############Secondary Alb ##################

module "secondary_alb" {
  source            = "./us-west-2/modules/load_balancers"
    providers = {
    aws = aws.secondary
  }
  frontend_alb_name = "frontend-alb"
  backend_alb_name  = "backend-alb"
  security_group_id = module.secondary_security_group.security_group_id
  public_subnet_ids = [module.secondary_network.public_subnet_ids[1], module.secondary_network.public_subnet_ids[0]]
  frontend_tg_name  = "frontend-tg"
  backend_tg_name   = "backend-tg"
  vpc_id            = module.secondary_network.vpc_id
}


# create AMIs from instances in us-east-1 ,copy them to us-west-2
module "ami_backup" {
  source = "./us-west-2/modules/ami_backup"

  providers = {
    aws = aws.secondary
  }

  source_amis     = {
   frontend = "ami-0eec7485a34edc3b8"
   backend = "ami-0084f9ebbb4f07bcd"
}
}

module "secondary_launch_templates" {
  source = "./us-west-2/modules/launch_templates"

  providers = {
    aws = aws.secondary
  }

  frontend_lt_name  = "frontend-lt-west"
  backend_lt_name   = "backend-lt-west"
  key_name          = "uswestkey"
  instance_type     = "t3.micro"
  security_group_id = module.secondary_security_group.security_group_id

  # Copied AMIs from us-east-1 → us-west-2
  ami_id_frontend = module.ami_backup.copied_ami_ids["frontend"]
  ami_id_backend  = module.ami_backup.copied_ami_ids["backend"]

  frontend_user_data = "frontend.sh"
  backend_user_data  = "backend.sh"
}

# Secondary Autoscaling group

module "secondary_autoscaling" {
  source               = "./us-west-2/modules/asg"
    providers = {
    aws = aws.secondary
  }
  frontend_asg_name    = "frontend-asg"
  backend_asg_name     = "backend-asg"
  asg_min_size         = 1
  asg_max_size         = 1
  asg_desired_capacity = 1
  frontend_subnet_ids  = [module.secondary_network.private_subnet_ids[0], module.secondary_network.private_subnet_ids[1]]
  backend_subnet_ids   = [module.secondary_network.private_subnet_ids[2], module.secondary_network.private_subnet_ids[3]]
  frontend_tg_arn      = module.secondary_alb.frontend_tg_arn
  backend_tg_arn       = module.secondary_alb.backend_tg_arn
  frontend_lt_west_id  =  module.secondary_launch_templates.frontend_lt_west_id
  backend_lt_west_id   = module.secondary_launch_templates.backend_lt_west_id
  depends_on = [module.secondary_launch_templates]

}

module "secondary_route53" {
  source              = "./us-west-2/modules/route53"
   providers = {
    aws = aws.secondary
  }
  vpc_id              = module.secondary_network.vpc_id
  alb_dns_name        = module.secondary_alb.alb_backend_dns
  alb_zone_id = module.secondary_alb.alb_backend_zone_id
}

module "secondary_bastion" {
  source            = "./us-east-1/modules/bastion"
  providers = {
    aws = aws.secondary
  }
  ami_id            = "ami-03aa99ddf5498ceb9"
  instance_type     = "t2.micro"
  key_name          = "uswestkey"
  public_subnet_id  = module.secondary_network.public_subnets[0]
  security_group_id = module.secondary_security_group.security_group_id

}

output "secondary_jump_server" {
  value = module.bastion.bastion_public_ip
}
