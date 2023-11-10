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

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

output "subnet" {
  value = module.subnets
}