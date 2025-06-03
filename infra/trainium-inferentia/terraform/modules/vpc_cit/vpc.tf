locals {
  vpc = {
    id = "vpc-020363f2ae1a0938c"
  }
}

data "aws_vpc" "aws_cit_anima_vpc" {
  id = local.vpc.id
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "tag:Name"
    values = ["aws-cit-anima-pubsubnet"]
  }
}

data "aws_subnet" "public_subnets" {
  for_each = toset(data.aws_subnets.public_subnets.ids)
  id = each.value
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "tag:Name"
    values = ["aws-cit-anima-privsubnet"]
  }
}

data "aws_subnet" "private_subnets" {
  count = 4
  id = data.aws_subnets.private_subnets.ids[0]
}