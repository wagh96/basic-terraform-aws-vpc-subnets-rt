variable "vpc_id" {
  description = "The ID of the VPC"
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "private_routes" {
  description = "List of private routes"
  type = list(object({
    cidr_block     = string
    nat_gateway_id = string
  }))
  default = []  # Allow for no additional routes
}