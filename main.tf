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

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "Subnet 1"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "Subnet 2"
  }
}

resource "aws_default_route_table" "public_rt" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  # vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "public route table"
  }
}

# resource "aws_route_table" "private_rt" {
#   vpc_id = aws_vpc.main.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.gw.id
#   }

#   route {
#     cidr_block = "10.0.0.0/16"
#     gateway_id = "local"
#   }

#   tags = {
#     Name = "private route table"
#   }
# }

# Associate Public Subnet with Public Route Table
# resource "aws_route_table_association" "public_subnet_assoc"{
#     count = 1
#     route_table_id = aws_default_route_table.public_rt.id
#     subnet_id = aws_subnet.public_subnet.id
#     depends_on = [aws_route_table.public_route,aws_subnet.public_subnet]    
# }

# resource "aws_route_table_association" "private_subnet_assoc"{
#     count = 1
#     route_table_id = aws_route_table.private_rt.id
#     subnet_id = aws_subnet.private_subnet.id
#     depends_on = [aws_route_table.private_route,aws_subnet.private_subnet]    
# }


#Resource to create s3 bucket - works
# resource "aws_s3_bucket" "pavlols3testb1"{
#   bucket = "pavlols3testb1"
#   tags = {
#     Name = "S3Bucket"
#   }
# }

# Upload an object - LOCK Error
# resource "aws_s3_bucket_object" "object" {
#   bucket = aws_s3_bucket.pavlols3testb1.id
#   key    = "profile"
#   acl = "public-read"
#   #acl    = "private"  # or can be "public-read"

#   source = "${path.module}/terravars.png"
#   # source = "myfiles/yourfile.txt"

#   etag = filemd5("${path.module}/terravars.png")
# }

# Security Group Creation for provisionerVPC

resource "aws_security_group" "dev_terraform_sg_allow_ssh_http"{
    name="dev-sg"
    vpc_id = aws_vpc.main.id
}

# Ingress Security Port 22 (Inbound)
resource "aws_security_group_rule" "ssh_ingress_access"{
    from_port = 22
    protocol = "tcp"
    security_group_id = aws_security_group.dev_terraform_sg_allow_ssh_http.id
    to_port = 22
    type = "ingress"
    cidr_blocks = ["10.0.0.0/16"]
}

# Ingress Security Port 80 (Inbound)
resource "aws_security_group_rule" "http_ingress_access"{
    from_port = 80
    protocol = "tcp"
    security_group_id = aws_security_group.dev_terraform_sg_allow_ssh_http.id
    to_port = 80
    type = "ingress"
    cidr_blocks = ["10.0.0.0/16"]
}

# All egress/outbound Access

resource "aws_security_group_rule" "all_egress_access"{
    from_port = 0
    protocol = "-1"
    security_group_id = aws_security_group.dev_terraform_sg_allow_ssh_http.id
    to_port = 0
    type = "egress"
    cidr_blocks = ["10.0.0.0/16"]
}


# create ec2
resource "aws_instance" "myEC-2" {
  ami = var.instance_id // "ami-0872c164f38dcc49f"
  instance_type = "t2.micro"
  associate_public_ip_address = false
  vpc_security_group_ids = [aws_security_group.dev_terraform_sg_allow_ssh_http.id]
  subnet_id = aws_subnet.public_subnet.id
  tags = {
    Name = "ec2_pc"
  }
}

# resource "aws_instance" "myBastion" {
#   ami = var.instance_id // "ami-0872c164f38dcc49f"
#   instance_type = var.instance_type // "t2.micro"
#   subnet_id = aws_subnet.private_subnet.id
#   vpc_security_group_ids = [aws_security_group.dev_terraform_sg_allow_ssh_http.id]
#   tags = {
#     Name = "bastion"
#   }
# }

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
