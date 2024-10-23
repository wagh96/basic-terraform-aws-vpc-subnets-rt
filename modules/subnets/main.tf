data "aws_availability_zones" "available" {}

resource "aws_subnet" "subnet" {
  count             = length(var.subnets)
  vpc_id            = var.vpc_id
  cidr_block        = var.subnets[count.index].cidr
  availability_zone = element(data.aws_availability_zones.available.names, count.index % length(data.aws_availability_zones.available.names))

  tags = {
    Name = "${var.subnets[count.index].type}-subnet-${count.index + 1}"
    Type = var.subnets[count.index].type
  }
}

