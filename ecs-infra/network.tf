data "aws_vpc" "ab2d-vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name_tag]
  }
}


data "aws_subnets" "ab2d-private-subnets" {
  filter {
    name   = "tag:Name"
    values = [ var.private_subnet_name_tag_a, var.private_subnet_name_tag_b ]
  }
}

data "aws_subnets" "ab2d-public-subnets" {
  filter {
    name   = "tag:Name"
    values = [var.public_subnet_name_tag_a, var.public_subnet_name_tag_b]
  }
}