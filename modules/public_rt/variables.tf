variable "vpc_id" {
  description = "The ID of the VPC"
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "public_routes" {
  description = "List of public routes"
  type = list(object({
    cidr_block = string
    gateway_id = string
  }))
}