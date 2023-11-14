resource "aws_subnet" "main" {
  for_each          = var.sub-subnets
  vpc_id            = var.vpc_id
  cidr_block        = each.value["cidr"]
  availability_zone = each.value["az"]
  tags              = merge(var.tags, { Name = "${var.env}-${each.key}" })

}

resource "aws_route_table" "main" {
  for_each = var.sub-subnets
  vpc_id   = var.vpc_id
  tags     = merge(var.tags, { Name = "${var.env}-${each.key}-rt" })
}

resource "aws_route_table_association" "route-association" {
  for_each       = var.sub-subnets
  subnet_id      = lookup(lookup(aws_subnet.main, each.key, null ), "id", null)
  route_table_id = lookup(lookup(aws_route_table.main, each.key, null ), "id", null)
}


variable "sub-subnets" {}
variable "vpc_id" {}
variable "tags" {}
variable "env" {}