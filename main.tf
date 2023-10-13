terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

#Provider profile and region in which all the resources will create
provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

#Resource to create s3 bucket - works
resource "aws_s3_bucket" "pavlols3testb1"{
  bucket = "pavlols3testb1"
  tags = {
    Name = "S3Bucket"
  }
}

# Upload an object - LOCK Error
resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.pavlols3testb1.id
  key    = "profile"
  acl = "public-read"
  #acl    = "private"  # or can be "public-read"

  source = "${path.module}/terravars.png"
  # source = "myfiles/yourfile.txt"

  etag = filemd5("${path.module}/terravars.png")
}

# create ec2

resource "aws_instance" "myEC-2" {
  ami = "ami-09100e341bda441c0"
  instance_type = "t2.micro"
  tags = {
    Name = "ec2pavlodeham91210"
  }
}


resource "aws_vpc" "main" {
 cidr_block = "10.0.0.0/16"
 instance_tenancy = "default"
 tags = {
   Name = "LYakhov VPC"
 }
}

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
 
variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

resource "aws_subnet" "public_subnets" {
 count      = length(var.public_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.public_subnet_cidrs, count.index)
 
 tags = {
   Name = "Public Subnet ${count.index + 1}"
 }
}
 
resource "aws_subnet" "private_subnets" {
 count      = length(var.private_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.private_subnet_cidrs, count.index)
 
 tags = {
   Name = "Private Subnet ${count.index + 1}"
 }
}

