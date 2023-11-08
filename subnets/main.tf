resource "aws_subnet" "main" {
  for_each = var.sub-subnets
  vpc_id = var.vpc_id
  cidr_block = each.value["cidr"]
  availability_zone = each.value["az"]
  tags = {
    Name = each.key
  }
}

variable "sub-subnets" {}
variable "vpc_id" {}