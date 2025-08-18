variable "frontend_lt_name" {
  type        = string
  description = "Frontend launch template name"
}

variable "backend_lt_name" {
  type        = string
  description = "Backend launch template name"
}

variable "key_name" {
  type        = string
  description = "EC2 Key Pair"
}

variable "ami_id_frontend" {
  type        = string
  description = "AMI ID for frontend (copied from us-east-1)"
}

variable "ami_id_backend" {
  type        = string
  description = "AMI ID for backend (copied from us-east-1)"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
  default     = "t3.micro"
}

variable "security_group_id" {
  type        = string
  description = "Security Group ID"
}

variable "frontend_user_data" {
  type        = string
  description = "Frontend user data script file name"
}

variable "backend_user_data" {
  type        = string
  description = "Backend user data script file name"
}

resource "aws_launch_template" "frontend_lt_west" {
  name          = var.frontend_lt_name
  key_name      = var.key_name
  image_id      = var.ami_id_frontend
  instance_type = var.instance_type
  user_data     = base64encode(file("${path.module}/${var.frontend_user_data}"))

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.security_group_id]
  }
}

resource "aws_launch_template" "backend_lt_west" {
  name          = var.backend_lt_name
  key_name      = var.key_name
  image_id      = var.ami_id_backend
  instance_type = var.instance_type
  user_data     = base64encode(file("${path.module}/${var.backend_user_data}"))

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.security_group_id]
  }
}

output "frontend_lt_west_id" {
  value = aws_launch_template.frontend_lt_west.id
}

output "backend_lt_west_id" {
  value = aws_launch_template.backend_lt_west.id
}
