resource "aws_vpc" "main" {
  cidr_block = var.cidr

  tags = {
    Name = var.tags
  }
}

module "subnets" {
  source      = "./subnets"
  for_each    = var.subnets
  sub-subnets = each.value
  vpc_id      = aws_vpc.main.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

resource "aws_route" "igw" {
  for_each               = lookup(lookup(module.subnets, "public", null), "route_table_ids", null)
  route_table_id         = each.value["id"]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_eip" "ngw" {
  for_each =   lookup(lookup(module.subnets, "public", null), "subnets_ids", null)
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  for_each = lookup(lookup(module.subnets, "public", null), "subnets_ids", null)
  allocation_id = lookup(aws_eip, each.value["id"], null )
  subnet_id = each.value["id"]
}

output "subnet" {
  value = module.subnets
}

