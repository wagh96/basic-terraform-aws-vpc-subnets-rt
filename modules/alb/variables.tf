variable "https_listner_protocol" {
  description = "alb https listner protocol"
  type        = string
  default     = "HTTPS"
}

variable "https_listner_port" {
  description = "alb https listner port"
  type        = string
  default     = "443"
}

variable "http_listner_protocol" {
  description = "alb http listner protocol"
  type        = string
  default     = "HTTP"
}

variable "http_listner_port" {
  description = "alb http listner port"
  type        = string
  default     = "80"
}


variable "sg_name" {
  description = "The name of the security group"
  type        = string
}

variable "sg_description" {
  description = "The description of the security group"
  type        = string
  default     = "Security group for ALB"
}

#variable "vpc_id" {
#  description = "The VPC ID where the resources will be created"
#  type        = string
#}

variable "alb_name" {
  description = "The name of the Application Load Balancer"
  type        = string
}

variable "alb_tg_name" {
  description = "The name of the Application Load Balancer Target Group"
  type        = string
}

variable "desync_mitigation_mode" {
  description = "The desync mitigation mode"
  type        = string
}

variable "drop_invalid_header_fields" {
  description = "Whether to drop invalid header fields"
  type        = bool
}

variable "internal" {
  description = "Set to true if the load balancer is internal"
  type        = bool
}

variable "load_balancer_type" {
  description = "The type of load balancer"
  type        = string
}

variable "ip_address_type" {
  description = "The type of IP addresses"
  type        = string
}

variable "idle_timeout" {
  description = "The idle timeout for the load balancer"
  type        = number
}

variable "preserve_host_header" {
  description = "Whether to preserve the host header"
  type        = bool
}

variable "enable_http2" {
  description = "Whether to enable HTTP/2"
  type        = bool
}

variable "enable_waf_fail_open" {
  description = "Whether to enable WAF fail open"
  type        = bool
}

#variable "subnets" {
#  description = "The subnets where the load balancer will be created"
#}

variable "target_group_port" {
  description = "Port for the target group"
  type        = number
  default     = "80"
}

variable "target_group_protocol" {
  description = "Protocol for the target group"
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "Target type for the target group"
  type        = string
}

variable "ssl_policy" {
  description = "SSL policy for the HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}

#variable "certificate_arn" {
#  description = "ARN of the SSL certificate"
#  type        = string
#}

variable "environment" {
  description = "Environment for the tags"
  type        = string
  default     = "dev"
}

variable "sg_tags" {
  description = "Tags for the security group"
  type        = map(string)
  default     = {
    Name        = "alb-sg"
    Environment = "dev"
  }
}

variable "alb_tags" {
  description = "Tags for the Application Load Balancer"
  type        = map(string)
  default     = {
    Name        = "alcon-alb"
    Environment = "dev"
  }
}

variable "tg_tags" {
  description = "Tags for the target group"
  type        = map(string)
  default     = {
    Name        = "alb-tg"
    Environment = "dev"
  }
}

variable "http_listener_tags" {
  description = "Tags for the HTTP listener"
  type        = map(string)
  default     = {
    Name        = "http-listener"
    Environment = "dev"
  }
}

variable "https_listener_tags" {
  description = "Tags for the HTTPS listener"
  type        = map(string)
  default     = {
    Name        = "https-listener"
    Environment = "dev"
  }
}

variable "aws_account_id" {
  description = "The AWS account ID to assume the role in"
  type        = string
}