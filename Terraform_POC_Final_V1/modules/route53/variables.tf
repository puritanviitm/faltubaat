variable "primary_alb_dns" {
  description = "Primary ALB DNS name"
  type        = string
}

variable "primary_alb_zone_id" {
  description = "Primary ALB hosted zone ID"
  type        = string
}

variable "secondary_alb_dns" {
  description = "Secondary ALB DNS name"
  type        = string
}

variable "secondary_alb_zone_id" {
  description = "Secondary ALB hosted zone ID"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "domain_name" {
  description = "Domain name for Route53 records"
  type        = string
}