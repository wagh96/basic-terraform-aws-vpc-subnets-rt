resource "aws_eip" "nat_eip" {
  count = length(var.subnet_ids)

  tags = {
    Name = "nat-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  count         = length(var.subnet_ids)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = var.subnet_ids[count.index]

  tags = {
    Name = "nat-gateway-${count.index + 1}"
  }
}