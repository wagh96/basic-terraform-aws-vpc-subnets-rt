resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route" "public_routes" {
  count = length(var.public_routes)

  route_table_id = aws_route_table.public_route_table.id
  destination_cidr_block = var.public_routes[count.index].cidr_block
  gateway_id     = var.public_routes[count.index].gateway_id
}

resource "aws_route_table_association" "public_association" {
  count          = length(var.public_subnet_ids)
  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public_route_table.id
}