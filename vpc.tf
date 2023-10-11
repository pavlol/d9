# VPC Creation using CIDR block available in vars.tf
# .Copy_VPC Creation using CIDR block available in vars.tf
resource "aws_vpc" "provisionerVPC"{
    cidr_block = var.vpc_cidr
    enable_dns_hostnames=true
    enable_dns_support = true

    tags = {
        Name = "dev-terraform-vpc"
    }
}
