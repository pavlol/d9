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

#Resource to create s3 bucket
# resource "aws_s3_bucket" "pavlols3testb1"{
#   bucket = "pavlols3testb1"

#   tags = {
#     Name = "S3Bucket"
#   }
# }



