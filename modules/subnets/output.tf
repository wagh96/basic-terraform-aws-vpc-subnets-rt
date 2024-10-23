output "public_subnet_ids" {
  value = [for s in aws_subnet.subnet : s.id if s.tags["Type"] == "public"]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.subnet : s.id if s.tags["Type"] == "private"]
}