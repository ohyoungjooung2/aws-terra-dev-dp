resource "aws_subnet" "dev_subnet_pub1" {
      availability_zone = "ap-northeast-2a"
      cidr_block = "10.3.1.0/24"
      vpc_id = "${aws_vpc.dev-vpc.id}"
      map_public_ip_on_launch = "true"
      tags = "${
         map(
         "Name","dev_subnet_pub",
         )
      }"
}


resource "aws_internet_gateway" "dev-gw" {
      vpc_id = "${aws_vpc.dev-vpc.id}"
      tags =  {
          Name = "terraform-dev-gw"
      }
}

resource "aws_route_table" "dev-pub-rt" {
      vpc_id = "${aws_vpc.dev-vpc.id}"
      route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.dev-gw.id}"
      }
}

resource "aws_route_table_association" "rt-association1" {
      subnet_id = "${aws_subnet.dev_subnet_pub1.id}"
      route_table_id = "${aws_route_table.dev-pub-rt.id}"
}

resource "aws_security_group" "dev_pub_sg" {
        name = "terraform_dev_pub_sg"
	description = "Security group for all worker nodes in pub 1 sbnet" 
	vpc_id = "${aws_vpc.dev-vpc.id}"
        ingress {
          from_port = 22
          to_port = 22
          protocol = "tcp"
          cidr_blocks = ["121.66.11.45/32","175.223.34.20/32"]
        }
        ingress {
          from_port = 8000
          to_port = 8000
          protocol = "tcp"
          cidr_blocks = ["121.66.11.45/32","175.223.34.20/32"]
        }
        ingress {
          from_port = 80
          to_port = 80
          protocol = "tcp"
          cidr_blocks = ["121.66.11.45/32","175.223.34.20/32"]
        }
        egress {
          from_port = 80
          to_port = 80
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }

     
        egress {
          from_port = 443
          to_port = 443
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }

        egress {
          from_port = 3308
          to_port = 3308
          protocol = "tcp"
          cidr_blocks = ["10.3.2.0/24","10.3.3.0/24"]
        }

        tags = "${
          map(
          "Name" , "terraform-dev-pub-node",
          )
        }"
}

#resource "aws_security_group_rule" "dev_pub_sg_gr" {
#        description = "Allow to be outed to rds instance sbnet"
#        from_port = 3308
#        protocol = "tcp"
#        security_group_id = "${aws_security_group.dev_pub_sg.id}"
#        #To rds
#        cidr_blocks = ["10.3.2.0/24","10.3.3.0/24"]
#        #source_security_group_id = "${aws_security_group.dev-rds-sg.id}"
#        to_port = 3308
#        type = "egress"
#}

#Aws key generate
resource "aws_key_pair" "dev_pub" {
  key_name   = "dev_pub"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDjDcOSrVbS5QZz/z42Pw05yxWV/3eJLZrQ9FNMEoia6BIuPWLQ+Osc51CSmoqlhDzyz4K0qKaCcMb9CVvstoIQ2hgd7jfpwz/kYmkliRPpEtc9MijbaGjDbqgcOySh0okLathZZ56BNXkx+Yzs6DGDuL4AfrvnZoLk6RQ9Jprw334lzn9EJuVZX8KTMMbbd+U90aXOF2JL0mkow4uQ0XGfH06m5DUBV6Pibrfq2DrzcNLAUH3jEuWPgE4Abxaucbw5GIezwjN3hMY4ZSPbtIP0ju4T2ytxcrI9RQZaJvDMwZUgHcF06Efmka7u0PI8jpQiDYR2gV8KnKpIY0+GKb3P53KEI1MhVfSM1UcX65guhAf2CuB+o++rdIkbwJVdx4SDTXHSPy2Sa66xA22uudIwj41ybWaav6JWAQzyTWC6Wo3djxRz/bzIkp87Ji/kp26keoVktgeRZ5y966NqSoES04oFxHWXWGH12me6tWHjMXCd7ZGpVwyiu0F7pKyGzrM= oyj@DESKTOP-JM7824V"
}


resource "aws_instance" "dev_pub_ami" {
	ami = "${lookup(var.aws_dev_pub_ami, var.aws_region)}"
	instance_type = "t2.micro"
	key_name = "dev_pub"
	vpc_security_group_ids = ["${aws_security_group.dev_pub_sg.id}"]
	subnet_id = "${aws_subnet.dev_subnet_pub1.id}"
	associate_public_ip_address = true
	source_dest_check = false
	#user_data = "${file("nat-user-data.yml")}"
	tags = {
		Name = "dev_pub_instance"
	}
}
