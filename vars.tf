variable "vpc_cidr"{
    default = "10.0.1.0/24"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "instance_id"{
    type = string
    default="ami-0872c164f38dcc49f"
}
