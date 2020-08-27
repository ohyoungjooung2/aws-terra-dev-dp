resource "aws_subnet" "dev_subnet_pub1" {
  availability_zone       = "ap-northeast-2a"
  cidr_block              = "10.3.1.0/24"
  vpc_id                  = "${aws_vpc.dev-vpc.id}"
  map_public_ip_on_launch = "true"
  tags = "${
    map(
      "Name", "dev_subnet_pub",
    )
  }"
}

resource "aws_internet_gateway" "dev-gw" {
  vpc_id = "${aws_vpc.dev-vpc.id}"
  tags = {
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
  subnet_id      = "${aws_subnet.dev_subnet_pub1.id}"
  route_table_id = "${aws_route_table.dev-pub-rt.id}"
}

#Myip check to add sg group
data "http" "myip" {
  #url = "http://checkip.amazonaws.com"
  url = "http://ipv4.icanhazip.com"
   request_headers = {
    Accept = "application/json"
    #Accept = "Content-Type: text/plain; charset=utf-8"
  }
}

resource "aws_security_group" "dev_pub_sg" {
  name        = "terraform_dev_pub_sg"
  description = "Security group for all worker nodes in pub 1 sbnet"
  vpc_id      = "${aws_vpc.dev-vpc.id}"
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    self        = true
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    self        = true
  }
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    self        = true
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }


  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  #To db rds subnet
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    #cidr_blocks = ["10.3.2.0/24", "10.3.3.0/24"]
    self        = true
  }
  #Mysql self allow(only)
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    self        = true
  }

  tags = "${
    map(
      "Name", "terraform-dev-pub-node",
    )
  }"
}

#For rds(product or stage)
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
  key_name = "dev_pub"
  public_key = file("/home/oyj/.ssh/id_rsa.pub")
}

#For rds(product or stage)
#Db connect
#data "aws_db_instance" "database" {
#  db_instance_identifier = "dev-rds-mysl"
#  depends_on = [
#    aws_db_instance.default,
#  ]
#}
#
#output "db_instance_addr" {
#  value = "${aws_db_instance.default.endpoint}"
#}

resource "aws_instance" "dev_pub_ami" {
  ami                         = "${lookup(var.aws_dev_pub_ami, var.aws_region)}"
  instance_type               = "t2.micro"
  key_name                    = "dev_pub"
  vpc_security_group_ids      = ["${aws_security_group.dev_pub_sg.id}"]
  subnet_id                   = "${aws_subnet.dev_subnet_pub1.id}"
  associate_public_ip_address = true
  source_dest_check           = false
  #user_data = "${file("nat-user-data.yml")}"

  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host = self.public_ip
  }
  
  provisioner "file" {
    source = "mysql_auth.sh"
    destination = "/tmp/mysql_auth.sh"
  }

  provisioner "file" {
    source = "vue-spboot-mysl-0.0.1-SNAPSHOT.jar"
    destination = "/home/ec2-user/vue-spboot-mysl-0.0.1-SNAPSHOT.jar"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install java-1.8.0-openjdk.x86_64",
      "sudo yum -y install mysql",
      "sudo yum -y install httpd",
      #"sudo yum -y install tomcat8 tomcat8-webapps.noarch",
      "sudo yum -y install mariadb-server",
      "sudo systemctl enable mariadb",
      "sudo systemctl start mariadb",
      "chmod +x /tmp/mysql_auth.sh",
      "bash /tmp/mysql_auth.sh",
      "sudo chmod 700 /home/ec2-user/vue-spboot-mysl-0.0.1-SNAPSHOT.jar",
      "sudo ln -s /home/ec2-user/vue-spboot-mysl-0.0.1-SNAPSHOT.jar /etc/init.d/vsm",
      "sudo chkconfig --add vsm",
      "sudo chkconfig --level 234 vsm on",
      "sudo service vsm start",
    ]

  }

  tags = {
    Name = "dev_pub_instance"
  }
   
}

output "instance_ip_addr" {
  value = aws_instance.dev_pub_ami.public_ip
}
