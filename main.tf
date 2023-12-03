terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

#Provider profile and region in which all the resources will create
provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_vpc" "main" {
 cidr_block = "10.0.0.0/16"
 instance_tenancy = "default"
 tags = {
   Name = "Lyakhov VPC"
 }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main gateway"
  }
}

data "aws_availability_zones" "available" {}

#Resource to create s3 bucket - works
resource "aws_s3_bucket" "pavlols3testb1"{
  bucket = "pavlols3testb1"
  tags = {
    Name = "S3Bucket"
  }
}


# create ec2
resource "aws_instance" "myEC-2" {
  ami = var.instance_id // "ami-0872c164f38dcc49f"
  instance_type = var.instance_type
  availability_zone = data.aws_availability_zones.available.names[0]
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.dev_terraform_sg_allow_ssh_http.id]
  subnet_id = aws_subnet.public_subnet.id
  tags = {
    Name = "ec2_pc"
  }
  user_data = file("user_data.sh")
}

# Instance Configuration
resource "aws_instance" "provisioner-remoteVM"{
    ami = var.instance_id // "ami-0872c164f38dcc49f"
    instance_type = var.instance_type
    #key_name = "ASIARGBPKAIJEMWLHQNO"
    vpc_security_group_ids = [aws_security_group.dev_terraform_sg_allow_ssh_http.id]
    subnet_id = aws_subnet.public_subnet.id

    tags = {
        Name = "remote-instance"
    }

    provisioner "remote-exec"{
        inline = [
            "sudo yum update -y",
            "sudo yum install -y nginx",
            "sudo service nginx start"
        ]
        on_failure = continue
    }
    provisioner "local-exec"{

        #ami=data.aws_ami.packeramis.id
        #instance_type="t2.micro"
        #when = "destroy"
        command = "echo Instance Type=${self.instance_type},Instance ID=${self.id},Public DNS=${self.public_dns},AMI ID=${self.ami} >> allinstancedetails"
    }
    connection {
        type = "ssh"
        host = aws_instance.provisioner-remoteVM.public_ip
        user = "ec2-user"
        private_key=file("labsuser-7.pem")
        //private_key=file("${path.module}/labsuser-7.pem")
    }

}
