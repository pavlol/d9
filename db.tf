resource "aws_db_instance" "instance_db" {
  allocated_storage = 10
  availability_zone = data.aws_availability_zones.available.names[0]
  identifier        = "database"
  # db_name                = "database"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = "localdb"
  password               = "password1"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_gr.name
  vpc_security_group_ids = [aws_security_group.sg_db_ssh_allow.id]

  provisioner "local-exec" {
    command = "echo DB instance = ${self.endpoint} >> metadata"
  }
}
