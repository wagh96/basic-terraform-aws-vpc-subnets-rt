resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route" "private_routes" {
  count = length(var.private_routes)

  route_table_id = aws_route_table.private_route_table.id
  destination_cidr_block = var.private_routes[count.index].cidr_block
  nat_gateway_id = var.private_routes[count.index].nat_gateway_id
}

resource "aws_route_table_association" "private_association" {
  count          = length(var.private_subnet_ids)
  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private_route_table.id
}