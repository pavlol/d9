# Security Group Creation for provisionerVPC

resource "aws_security_group" "dev_terraform_sg_allow_ssh_http"{
    name="dev-sg"
    vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "sg_db_ssh_allow" {
  name        = "allow_ssh"
  description = "allow DB SSH traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "allow_ssh_db"
  }
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
