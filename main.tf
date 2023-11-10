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
  tags   = {
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
  #for_each = lookup(lookup(module.subnets, "public", null), "subnets_ids", null)
  count  = length(local.private_subnet_ids)
  domain = "vpc"
  tags   = {
    Name = "ngw-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "ngw" {
  #for_each     = lookup(lookup(module.subnets, "public", null), "subnets_ids", null)
  count         = length(local.public_subnet_ids)
  allocation_id = element(aws_eip.ngw.*.id, count.index )
  subnet_id     = element(local.public_subnet_ids, count.index )
  tags          = {
    Name = "public-ngw-${count.index + 1}"
  }
}


resource "aws_route" "ngw" {
  count                  = length(local.private_route_table_ids)
  route_table_id         = element(local.private_route_table_ids, count.index )
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.ngw.*.id, count.index )
}


output "subnet" {
  value = module.subnets
}

