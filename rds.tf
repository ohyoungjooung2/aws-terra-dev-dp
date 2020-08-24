resource "aws_db_instance" "default" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  identifier           = "dev-rds-mysl"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = "dev-db-sbnet"
  multi_az             = false
  port                 = 3308
  skip_final_snapshot  = true
  vpc_security_group_ids = [ aws_security_group.dev-rds-sg.id, ]
  depends_on = [
   aws_db_subnet_group.default,
  ]
}

resource "aws_security_group" "dev-rds-sg" {
  name = "dev-rds-sg"
  description = "dev rds security group"
  vpc_id = "${aws_vpc.dev-vpc.id}"
  ingress {
     from_port = 3308
     to_port = 3308
     protocol = "tcp"
     cidr_blocks = ["10.3.2.0/24","10.3.3.0/24"]
  }

}
#Sg group rule
resource "aws_security_group_rule" "rds-ingress" {
        description = "Allow pub  dev instance to connect rds"
        from_port = 3308
        protocol = "tcp"
        security_group_id = "${aws_security_group.dev-rds-sg.id}"
        source_security_group_id = "${aws_security_group.dev_pub_sg.id}"
        to_port = 3308
        type = "ingress"
}

resource "aws_db_subnet_group" "default" {
  name = "dev-db-sbnet"
  subnet_ids = [aws_subnet.dev-db-subnet-1.id,aws_subnet.dev-db-subnet-2.id]

  tags = {
     Name = "My db sbnet grp"
  }

 # depends_on = [
 #    aws_db_instance.default,
 # ]

  
}
