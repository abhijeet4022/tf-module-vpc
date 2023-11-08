resource "aws_vpc" "main" {
  cidr_block = var.cidr

  tags = {
    Name = var.tags
  }
}

module "subnets" {
  source = "./subnets"
  for_each = var.subnets
  sub-subnets = each.value
  vpc_id = aws_vpc.main.id
}

