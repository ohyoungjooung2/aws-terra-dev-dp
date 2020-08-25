terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

  }

}
provider "aws" {
  version    = "~> 2.0"
  access_key = ""
  secret_key = ""
  region     = "ap-northeast-2"
}
