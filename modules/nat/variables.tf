variable "vpc_id" {
  description = "The ID of the VPC"
}

variable "subnet_ids" {
  description = "List of public subnet IDs for NAT Gateways"
  type = list(string)
}