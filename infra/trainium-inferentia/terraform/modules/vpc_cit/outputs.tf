output "vpc_id" {
  value = data.aws_vpc.aws_cit_anima_vpc.id
}

output "vpc_cidr_block" {
  value = data.aws_vpc.aws_cit_anima_vpc.cidr_block
}

output "vpc_secondary_cidr_blocks" {
  value = data.aws_vpc.aws_cit_anima_vpc.cidr_block
}

output "database_subnet_group" {
  value = null
}

output "public_subnets" {
  value = [for s in data.aws_subnet.public_subnets : s.id]
}

output "public_subnets_cidr_blocks" {
  value = [for s in data.aws_subnet.public_subnets : s.cidr_block]
}

output "private_subnets" {
  value = [for s in data.aws_subnet.private_subnets : s.id]
}

output "private_subnets_cidr_blocks" {
  value = [for s in data.aws_subnet.private_subnets : s.cidr_block]
}
