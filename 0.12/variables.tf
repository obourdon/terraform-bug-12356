variable "aws_region" {
  description = "AWS Region"
  default     = "eu-west-1"
}

variable "aws_vpc_cidr" {
  default     = "192.168.0.0/16"
  description = "default cidr"
}

variable "aws_vpc_name" {
  default     = "Test VPC"
  description = "default name"
}

variable "aws_vpc_public_subnet_cidr_a" {
  default     = "192.168.1.0/24"
  description = "default public subnet"
}

variable "aws_vpc_public_subnet_cidr_b" {
  default     = "192.168.2.0/24"
  description = "default public subnet"
}

variable "aws_vpc_public_subnet_cidr_c" {
  default     = "192.168.3.0/24"
  description = "default public subnet"
}
