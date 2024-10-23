variable "vpc_id" {
  description = "The ID of the VPC"
}

variable "subnets" {
  description = "A list of subnets with CIDR and type"
  type = list(object({
    cidr = string
    type = string
  }))
}
