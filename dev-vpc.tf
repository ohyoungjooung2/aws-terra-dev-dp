resource "aws_vpc" "dev-vpc" {
      cidr_block = "10.3.0.0/16"
      tags = "${
        map(
        "Name", "terraform-dev-node",
        )
      }"
}

#data "aws_availability_zones" "available" {}

#priv db subnet
resource "aws_subnet" "dev-db-subnet-1" {
      availability_zone = "ap-northeast-2a"
      cidr_block = "10.3.2.0/24"
      vpc_id = "${aws_vpc.dev-vpc.id}"
      tags = "${
         map(
         "Name","terraform-dev-db-subnet-1",
         )
      }"
}

resource "aws_subnet" "dev-db-subnet-2" {
      availability_zone = "ap-northeast-2c"
      cidr_block = "10.3.3.0/24"
      vpc_id = "${aws_vpc.dev-vpc.id}"
      tags = "${
         map(
         "Name","terraform-dev-db-subnet-2",
         )
      }"
}
