data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["alcon-vpc"] # Replace with your VPC name
  }
}

module "igw" {
  source = "./modules/igw"
  vpc_id = data.aws_vpc.vpc.id
  igw_name = "alcon-igw"
}

module "nat_gw" {
  source      = "./modules/nat"
  vpc_id      = data.aws_vpc.vpc.id
  subnet_ids  = module.public_subnets.public_subnet_ids
}

module "public_subnets" {
  source   = "./modules/subnets"
  vpc_id   = data.aws_vpc.vpc.id
  subnets  = [
    { cidr = "10.0.0.0/24", type = "public" },
    { cidr = "10.0.1.0/24", type = "public" },
    { cidr = "10.0.2.0/24", type = "public" }
  ]
}

module "private_subnets" {
  source   = "./modules/subnets"
  vpc_id   = data.aws_vpc.vpc.id
  subnets  = [
    { cidr = "10.0.3.0/24", type = "private" },
    { cidr = "10.0.4.0/24", type = "private" },
    { cidr = "10.0.5.0/24", type = "private" },
    { cidr = "10.0.6.0/24", type = "private" },
    { cidr = "10.0.7.0/24", type = "private" },
    { cidr = "10.0.8.0/24", type = "private" }
  ]
}


module "public_rt" {
  source            = "./modules/public_rt"
  vpc_id            = data.aws_vpc.vpc.id
  public_subnet_ids = module.public_subnets.public_subnet_ids

  public_routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.igw.igw_id  # Reference to the Internet Gateway
    }
  ]
}

module "private_rt" {
  source             = "./modules/private_rt"
  vpc_id             = data.aws_vpc.vpc.id
  private_subnet_ids = module.private_subnets.private_subnet_ids

  private_routes = [
    for nat_id in module.nat_gw.nat_ids : {
      cidr_block     = "0.0.0.0/0"  # Outbound traffic from private subnets
      nat_gateway_id = nat_id
    }
  ]
}

module "apigw" {
  source          = "./modules/apigw"
  api_name        = "alcon-api"
  api_description = "This is my API"
  env             = "dev"
  stage_name      = "dev"
}

module "alb" {
  source = "./modules/alb"

  aws_account_id                 = "533267073975"
  sg_name                        = "alb-sg"
  alb_name                       = "alcon-alb"
  alb_tg_name                    = "alcon-tg-alb"
  desync_mitigation_mode         = "defensive"
  drop_invalid_header_fields      = true
  internal                       = false
  load_balancer_type             = "application"
  ip_address_type                = "ipv4"
  idle_timeout                   = 60
  preserve_host_header           = true
  enable_http2                   = true
  enable_waf_fail_open           = false
  target_type                    = "ip"
}