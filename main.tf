# Primary region provider
provider "aws" {
  region = "us-east-1"
  alias  = "primary"
}

# Secondary region provider
provider "aws" {
  region = "us-west-2"
  alias  = "secondary"
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







module "network" {
  source = "./us-west-2/modules/network"

  vpc_cidr =  "170.20.0.0/16"
  
   public_subnets = [  
    { cidr = "170.20.1.0/24", az = "us-west-2a" },
    { cidr = "170.20.2.0/24", az = "us-west-2b" }
   ]

   private_subnets =  [
    { cidr = "170.20.3.0/24", az = "us-west-2a" },
    { cidr = "170.20.4.0/24", az = "us-west-2b" },
    { cidr = "170.20.5.0/24", az = "us-west-2a" },
    { cidr = "170.20.6.0/24", az = "us-west-2b" },
    { cidr = "170.20.7.0/24", az = "us-west-2a" },
    { cidr = "170.20.8.0/24", az = "us-west-2b" }
  ]


output "vpc_output_from_nwmodule" {
  
  value = module.network.vpc_id
}

# # Module: Security Groups
module "security_group" {
  source              = "./us-west-2/modules/security"
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

  domain_name = "b15facebook.xyz"
  san_names   = ["*.b15facebook.xyz"]
}
