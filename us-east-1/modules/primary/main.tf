# DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = var.db_subnet_ids
}

# Primary DB instance
resource "aws_db_instance" "primary" {
  #count = length(trimspace(var.replicate_source_db)) == 0 ? 1 : 0
#  count                   = var.replicate_source_db == "" ? 1 : 0
  count = var.create_primary ? 1 : 0

  identifier              = var.db_identifier
  allocated_storage       = var.db_allocated_storage
  engine                  = var.db_engine
  instance_class          = var.db_instance_class
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  vpc_security_group_ids  = [var.db_security_group_id]
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = true
}

# us-west-2 DB subnet group
# resource "aws_db_subnet_group" "secondary_db_subnet_group" {
#   provider   = aws.secondary
#   name       = "secondary-db-subnet-group"
#   subnet_ids = [
#     module.secondary_network.private_subnet_ids[0], # subnet 7
#     module.secondary_network.private_subnet_ids[1]  # subnet 8
#   ]
#   tags = {
#     Name = "Secondary DB Subnet Group"
#   }
#}

# Read Replica
provider "aws" {
  alias  = "secondary"
  region = "us-west-2"
  
}
resource "aws_db_instance" "replica" {
  provider = aws.secondary
    count               = var.create_replica ? 1 : 0

#  count                   = var.replicate_source_db != "" ? 1 : 0
  replicate_source_db     = var.replicate_source_db # MUST be ARN
  instance_class          = var.db_instance_class
  vpc_security_group_ids  = [var.db_security_group_id]
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = true
}
