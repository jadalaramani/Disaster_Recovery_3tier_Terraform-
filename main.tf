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



#  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1a", "us-east-1b", "us-east-1a", "us-east-1b"]  # ✅ Added this line

 
#  private_subnet_cidrs = [
#     "170.20.3.0/24",
#     "170.20.4.0/24",
#     "170.20.5.0/24",
#     "170.20.6.0/24",
#     "170.20.7.0/24",
#     "170.20.8.0/24"
#   ]
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
    module.network.private_subnet_ids[0],
    module.network.private_subnet_ids[1]
  ]
  backup_retention_period = 7
}



# Secondary region

module "secondary_network" {
  source = "./us-west-2/modules/network"
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

# # Module: Security Groups
module "secondary_security_group" {
  providers = {
    aws = aws.secondary
  }
  source              = "./us-west-2/modules/security"
  vpc_id             = module.seconadry_network.vpc_id
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

module "secondary_rds" {
  source               = "./us-east-1/modules/primary"
  providers = {
    aws = aws.secondary
  }
  db_identifier        = "app-db-replica"
  db_engine            = "mysql"

  replicate_source_db  = module.rds.db_arn
  db_instance_class    = "db.t3.micro"
  db_security_group_id = module.secondary_security_group.security_group_id
  db_subnet_ids        = [
    module.secondary_network.private_subnet_ids[0],
    module.secondary_network.private_subnet_ids[1]
  ]
  backup_retention_period = 7
}



