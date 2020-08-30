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
