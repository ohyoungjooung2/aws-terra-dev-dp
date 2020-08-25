variable "aws_region" {
  default = "ap-northeast-2"
  type    = string
}


variable "aws_dev_pub_ami" {
  default = {
    #ap-northeast-2 = "ami-05a4cce8936a89f06"
    #ap-northeast-2 = "ami-0d777f54156eae7d9"
    ap-northeast-2 = "ami-08ffef921295fd55c"
  }
}
