#resource "aws_vpc" "main" {
#  cidr_block = "var.cidr"
#}

output "cidr" {
  value = "var.cidr"
}