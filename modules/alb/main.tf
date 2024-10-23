data "aws_vpc" "stackset_vpc" {
  filter {
    name   = "tag:aws:cloudformation:logical-id"
    values = ["VPC"]
  }
}  

# Retrieve Public Subnets
data "aws_subnet" "public_subnet_1" {
  filter {
    name   = "tag:aws:cloudformation:logical-id"
    values = ["PublicSubnet1"]
  }
}

# Retrieve Public Subnets
data "aws_subnet" "public_subnet_2" {
  filter {
    name   = "tag:aws:cloudformation:logical-id"
    values = ["PublicSubnet2"]
  }
}

resource "aws_security_group" "alb" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = data.aws_vpc.stackset_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.sg_tags
}

resource "aws_lb" "alb" {
  name                         = var.alb_name
  desync_mitigation_mode       = var.desync_mitigation_mode
  drop_invalid_header_fields    = var.drop_invalid_header_fields
  internal                     = var.internal
  load_balancer_type           = var.load_balancer_type
  ip_address_type              = var.ip_address_type
  idle_timeout                 = var.idle_timeout
  preserve_host_header         = var.preserve_host_header
  enable_http2                 = var.enable_http2
  enable_waf_fail_open         = var.enable_waf_fail_open
  security_groups              = [aws_security_group.alb.id]
  subnets                      = [data.aws_subnet.public_subnet_1.id,  data.aws_subnet.public_subnet_2.id]

  tags = var.alb_tags
}

resource "aws_lb_target_group" "target_group" {
  name     = var.alb_tg_name
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = data.aws_vpc.stackset_vpc.id
  target_type = var.target_type

  health_check {
    port                = 80
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold  = 2
    unhealthy_threshold = 2
  }

  tags = var.tg_tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.http_listner_port
  protocol          = var.http_listner_protocol

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = var.http_listener_tags
}

data "aws_acm_certificate" "acm" {
  domain      = "adi.planner.dev.myalcon.com"  # Replace with your domain
  statuses    = ["ISSUED"]      # Optional: filter by certificate status
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.https_listner_port
  protocol          = var.https_listner_protocol
  ssl_policy        = var.ssl_policy
  certificate_arn   = data.aws_acm_certificate.acm.arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  tags = var.https_listener_tags
}